-- Hand-configured starpls: overrides nvim-lspconfig's bundled lsp/starpls.lua.
--
-- starpls is the ONLY Starlark server with a real builtin documentation corpus
-- (Bazel's own `builtins/*.html` docs are compiled into the binary), so it is
-- what backs `K` hover, signature help, document symbols and references on
-- `bzl` buffers. buck2's own `buck2 lsp` resolves labels/targets but has no
-- doc corpus; starlark-rust advertises `hoverProvider` but returns an empty
-- `contents` array -- it is a linter, not a source of hints.
--
-- The catch: starpls is Bazel-only. Its binary contains no Buck2 support
-- whatsoever, so in a Buck2 repo it (a) fails `bazel info` on attach and
-- (b) flags every Buck2/native global as undefined. Both are handled below.
-- See docs/adding-a-language-server.md (Path B).

-- True when the client's workspace is a Buck2 repo rather than a Bazel one.
local function is_buck2_workspace(client)
  local root = client and client.root_dir
  if not root then
    return false
  end
  return vim.uv.fs_stat(root .. '/.buckconfig') ~= nil
end

---@type vim.lsp.Config
return {
  cmd = {
    'starpls',
    'server',
    -- Infer attributes on a rule implementation's `ctx` param, so `ctx.attr.*`
    -- and `ctx.actions.*` hover/complete inside `def _impl(ctx):`.
    '--experimental_infer_ctx_attributes',
    -- Better typechecking through branches; improves hover accuracy.
    '--experimental_use_code_flow_analysis',
    -- NOTE: deliberately NOT passing --experimental_enable_label_completions;
    -- it enumerates workspace targets via Bazel, which cannot work here.
  },
  filetypes = { 'bzl' },
  -- Bundled config only lists Bazel markers (WORKSPACE/MODULE.bazel), so in a
  -- Buck2 repo starpls would attach with a nil root. Add the Buck2 markers.
  root_markers = { '.buckconfig', 'WORKSPACE', 'WORKSPACE.bazel', 'MODULE.bazel', '.git' },

  handlers = {
    -- starpls shells out to `bazel info` on attach and reports the failure as
    -- a type=1 (Error) window/showMessage. In a Buck2 repo that failure is
    -- expected and permanent -- there is no Bazel workspace to find -- so the
    -- popup is pure noise. Swallow only that one message; let everything else
    -- through to the default handler.
    ['window/showMessage'] = function(err, result, ctx)
      if
        result
        and type(result.message) == 'string'
        and result.message:find('Failed to fetch Bazel configuration', 1, true)
      then
        return
      end
      return vim.lsp.handlers['window/showMessage'](err, result, ctx)
    end,

    -- In a Buck2 repo, starpls resolves none of the Buck2 prelude or `native`,
    -- so its `"x" is not defined` diagnostics are false positives on nearly
    -- every line. Drop just that class; keep syntax errors, unused-symbol
    -- warnings, and everything else it reports. In a real Bazel workspace
    -- (no .buckconfig) nothing is filtered.
    --
    -- TRADEOFF: this also hides genuine typos, since starpls cannot tell an
    -- unresolvable prelude symbol from a misspelled one. Set
    -- `vim.g.starpls_filter_undefined = false` to see them all again.
    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      local filtering = vim.g.starpls_filter_undefined ~= false
      if result and result.diagnostics and filtering and is_buck2_workspace(client) then
        result.diagnostics = vim.tbl_filter(function(d)
          return not (type(d.message) == 'string' and d.message:match('^".*" is not defined$'))
        end, result.diagnostics)
      end
      return vim.lsp.handlers['textDocument/publishDiagnostics'](err, result, ctx, config)
    end,
  },
}
