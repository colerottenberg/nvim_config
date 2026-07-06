-- Native LSP engine (replaces AstroLSP).
--
-- Provides, using Neovim 0.11+/0.12 built-ins:
--   * on-attach buffer-local mappings with capability/`cond` gating
--   * format-on-save driven by a `vim.b.autoformat` flag (ignoring cpp/c/cuda)
--   * global feature toggles (codelens, inlay hints, inline completion, linked
--     editing range, semantic tokens)
--   * default capabilities merged from blink.cmp
--   * per-server settings via `vim.lsp.config`, enablement via `vim.lsp.enable`
--     and mason-lspconfig's `automatic_enable`
--
-- Server-specific configs live with their language module (e.g. clangd in
-- `plugins/lang/cpp.lua`); rust_analyzer is owned by rustaceanvim.

-- Feature flags (formerly astrolsp `features`).
local features = {
  codelens = true,
  inlay_hints = true,
  inline_completion = true,
  linked_editing_range = true,
  semantic_tokens = true,
}

-- Formatting config (formerly astrolsp `formatting`).
local formatting = {
  format_on_save = {
    enabled = true,
    allow_filetypes = {},
    ignore_filetypes = { "cpp", "c", "cuda" },
  },
  disabled = {}, -- server names for which formatting is disabled (true = all)
  timeout_ms = 1000,
}

-- Global autoformat switch (toggled by <Leader>uF); buffers may override via
-- vim.b.autoformat (toggled by <Leader>uf).
vim.g.autoformat = formatting.format_on_save.enabled

-- ── Default capabilities (blink.cmp) ──────────────────────────────────────
do
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then caps = blink.get_lsp_capabilities(caps) end
  vim.lsp.config("*", { capabilities = caps })
end

-- ── Toggle helpers (formerly astrolsp.toggles) ────────────────────────────
local function notify(msg, value) vim.notify(("%s %s"):format(msg, value and "on" or "off"), vim.log.levels.INFO) end
local toggles = {
  buffer_autoformat = function()
    local buf = vim.api.nvim_get_current_buf()
    local cur = vim.b[buf].autoformat
    if cur == nil then cur = vim.g.autoformat end
    vim.b[buf].autoformat = not cur
    notify("Buffer autoformatting", vim.b[buf].autoformat)
  end,
  autoformat = function()
    vim.g.autoformat = not vim.g.autoformat
    notify("Global autoformatting", vim.g.autoformat)
  end,
  buffer_inlay_hints = function()
    local buf = vim.api.nvim_get_current_buf()
    local enabled = not vim.lsp.inlay_hint.is_enabled { bufnr = buf }
    vim.lsp.inlay_hint.enable(enabled, { bufnr = buf })
    notify("Buffer inlay hints", enabled)
  end,
  inlay_hints = function()
    local enabled = not vim.lsp.inlay_hint.is_enabled {}
    vim.lsp.inlay_hint.enable(enabled)
    notify("Global inlay hints", enabled)
  end,
  codelens = function()
    features.codelens = not features.codelens
    vim.lsp.codelens.enable(features.codelens, { bufnr = 0 })
    notify("CodeLens", features.codelens)
  end,
  buffer_semantic_tokens = function()
    local buf = vim.api.nvim_get_current_buf()
    for _, client in ipairs(vim.lsp.get_clients { bufnr = buf }) do
      if client:supports_method "textDocument/semanticTokens/full" then
        vim.lsp.semantic_tokens[vim.b[buf].semantic_tokens_disabled and "start" or "stop"](buf, client.id)
      end
    end
    vim.b[buf].semantic_tokens_disabled = not vim.b[buf].semantic_tokens_disabled
    notify("Buffer semantic tokens", not vim.b[buf].semantic_tokens_disabled)
  end,
}

-- ── Buffer-local mappings (applied on attach, with `cond`) ────────────────
-- `cond`: string = client:supports_method(<method>); function(client,bufnr);
-- boolean; or nil (always). Where snacks is available its pickers replace the
-- default vim.lsp.buf.* (this mirrors astrocommunity's picker-lsp-mappings).
local function picker(name, cfg)
  return function() require("snacks.picker")[name](cfg or {}) end
end
local has_snacks = pcall(require, "snacks")

local mappings = {
  n = {
    ["<Leader>la"] = { vim.lsp.buf.code_action, desc = "LSP code action", cond = "textDocument/codeAction" },
    ["<Leader>lA"] = {
      function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
      desc = "LSP source action",
      cond = "textDocument/codeAction",
    },
    ["<Leader>ll"] = {
      function() vim.lsp.codelens.enable(true, { bufnr = 0 }) end,
      desc = "LSP CodeLens refresh",
      cond = "textDocument/codeLens",
    },
    ["<Leader>lL"] = { vim.lsp.codelens.run, desc = "LSP CodeLens run", cond = "textDocument/codeLens" },
    ["<Leader>uL"] = { toggles.codelens, desc = "Toggle CodeLens", cond = "textDocument/codeLens" },
    ["gD"] = { vim.lsp.buf.declaration, desc = "Declaration of current symbol", cond = "textDocument/declaration" },
    ["gd"] = {
      has_snacks and picker "lsp_definitions" or vim.lsp.buf.definition,
      desc = "Show the definition of current symbol",
      cond = "textDocument/definition",
    },
    ["gy"] = {
      has_snacks and picker "lsp_type_definitions" or vim.lsp.buf.type_definition,
      desc = "Definition of current type",
      cond = "textDocument/typeDefinition",
    },
    ["gI"] = {
      has_snacks and picker "lsp_implementations" or vim.lsp.buf.implementation,
      desc = "Implementation of current symbol",
      cond = "textDocument/implementation",
    },
    ["grr"] = {
      has_snacks and picker "lsp_references" or vim.lsp.buf.references,
      desc = "References of current symbol",
      cond = "textDocument/references",
    },
    ["gri"] = {
      has_snacks and picker "lsp_implementations" or vim.lsp.buf.implementation,
      desc = "Implementation of current symbol",
      cond = "textDocument/implementation",
    },
    ["gO"] = {
      has_snacks and picker "lsp_symbols" or vim.lsp.buf.document_symbol,
      desc = "Document symbols",
      cond = "textDocument/documentSymbol",
    },
    ["<Leader>lf"] = {
      function() vim.lsp.buf.format { timeout_ms = formatting.timeout_ms } end,
      desc = "Format buffer",
      cond = "textDocument/formatting",
    },
    ["<Leader>lr"] = { vim.lsp.buf.rename, desc = "Rename current symbol", cond = "textDocument/rename" },
    ["<Leader>lh"] = { vim.lsp.buf.signature_help, desc = "Signature help", cond = "textDocument/signatureHelp" },
    ["gK"] = { vim.lsp.buf.signature_help, desc = "Signature help", cond = "textDocument/signatureHelp" },
    ["<Leader>lw"] = {
      function()
        if vim.lsp.buf.workspace_diagnostics then vim.lsp.buf.workspace_diagnostics() end
      end,
      desc = "Workspace diagnostics",
      cond = "workspace/diagnostic",
    },
    ["<Leader>uf"] = {
      toggles.buffer_autoformat,
      desc = "Toggle autoformatting (buffer)",
      cond = "textDocument/formatting",
    },
    ["<Leader>uF"] = { toggles.autoformat, desc = "Toggle autoformatting (global)", cond = "textDocument/formatting" },
    ["<Leader>uh"] = {
      toggles.buffer_inlay_hints,
      desc = "Toggle inlay hints (buffer)",
      cond = "textDocument/inlayHint",
    },
    ["<Leader>uH"] = { toggles.inlay_hints, desc = "Toggle inlay hints (global)", cond = "textDocument/inlayHint" },
    ["<Leader>uY"] = {
      toggles.buffer_semantic_tokens,
      desc = "Toggle semantic highlight (buffer)",
      cond = function(client) return client:supports_method "textDocument/semanticTokens/full" end,
    },
  },
  x = {
    ["<Leader>la"] = { vim.lsp.buf.code_action, desc = "LSP code action", cond = "textDocument/codeAction" },
    ["<Leader>lf"] = {
      function() vim.lsp.buf.format { timeout_ms = formatting.timeout_ms } end,
      desc = "Format selection",
      cond = "textDocument/rangeFormatting",
    },
  },
}

local function check_cond(cond, client, bufnr)
  local t = type(cond)
  if t == "function" then return cond(client, bufnr) end
  if t == "string" then return client:supports_method(cond, bufnr) end
  if t == "boolean" then return cond end
  return true
end

-- Whether formatting is enabled for a given client (respects `disabled`).
local function formatting_enabled(client)
  local d = formatting.disabled
  return d ~= true and not vim.tbl_contains(d, client.name)
end

-- ── on_attach ─────────────────────────────────────────────────────────────
local function on_attach(client, bufnr)
  -- Buffer-local mappings.
  for mode, maps in pairs(mappings) do
    for lhs, spec in pairs(maps) do
      if check_cond(spec.cond, client, bufnr) then
        vim.keymap.set(mode, lhs, spec[1], { buffer = bufnr, desc = spec.desc, silent = true })
      end
    end
  end

  -- format-on-save flag (respects allow/ignore filetypes).
  if client:supports_method("textDocument/formatting", bufnr) and formatting_enabled(client) then
    if vim.b[bufnr].autoformat == nil then
      local ft = vim.bo[bufnr].filetype
      local fos = formatting.format_on_save
      local allow = vim.tbl_isempty(fos.allow_filetypes) or vim.tbl_contains(fos.allow_filetypes, ft)
      local ignore = not vim.tbl_isempty(fos.ignore_filetypes) and vim.tbl_contains(fos.ignore_filetypes, ft)
      vim.b[bufnr].autoformat = fos.enabled and allow and not ignore
    end
  end

  -- CodeLens: enable auto-refresh on attach if enabled.
  if features.codelens and client:supports_method("textDocument/codeLens", bufnr) then
    vim.lsp.codelens.enable(true, { bufnr = bufnr })
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then on_attach(client, args.buf) end
  end,
})

-- ── Format on save ────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("user_lsp_format_on_save", { clear = true }),
  callback = function(args)
    local enabled = vim.b[args.buf].autoformat
    if enabled == nil then enabled = vim.g.autoformat end
    if not enabled then return end
    vim.lsp.buf.format {
      bufnr = args.buf,
      timeout_ms = formatting.timeout_ms,
      filter = function(client) return formatting_enabled(client) end,
    }
  end,
})

-- ── CodeLens refresh (buffer) ─────────────────────────────────────────────
vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("user_lsp_codelens_refresh", { clear = true }),
  desc = "Refresh codelens (buffer)",
  callback = function(args)
    if not features.codelens then return end
    for _, client in ipairs(vim.lsp.get_clients { bufnr = args.buf }) do
      if client:supports_method "textDocument/codeLens" then
        vim.lsp.codelens.enable(true, { bufnr = args.buf })
        return
      end
    end
  end,
})

-- ── Global feature enablement ─────────────────────────────────────────────
if features.inlay_hints then vim.lsp.inlay_hint.enable(true) end
if features.codelens and vim.lsp.codelens.enable then vim.lsp.codelens.enable(true) end
if features.inline_completion and vim.lsp.inline_completion and vim.lsp.inline_completion.enable then
  vim.lsp.inline_completion.enable(true)
end
if features.linked_editing_range and vim.lsp.linked_editing_range and vim.lsp.linked_editing_range.enable then
  vim.lsp.linked_editing_range.enable(true)
end

-- ── Servers enabled without mason ─────────────────────────────────────────
-- (formerly astrolsp `servers = { "ruff" }`). mason-installed servers are
-- enabled by mason-lspconfig automatic_enable (see plugins/mason.lua).
vim.lsp.enable "ruff"
