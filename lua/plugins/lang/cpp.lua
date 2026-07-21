-- C / C++ / CUDA: clangd config + clangd_extensions + cmake-tools.
-- Buffer-local symbol keymaps live in after/ftplugin/cpp.lua.

-- Switch between source and header (clangd LSP command).
local function switch_source_header(bufnr)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
  if not client then return end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  client:request("textDocument/switchSourceHeader", params, function(err, result)
    if err then return vim.notify(tostring(err.message), vim.log.levels.ERROR) end
    if result then vim.cmd.edit(vim.uri_to_fname(result)) end
  end, bufnr)
end

return {
  {
    "p00f/clangd_extensions.nvim",
    lazy = true,
    init = function()
      -- clangd server settings (merged over the '*' defaults in config/lsp.lua).
      vim.lsp.config("clangd", {
        capabilities = { offsetEncoding = "utf-8" },
      })

      -- Load clangd_extensions and add the switch source/header mapping when
      -- clangd attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_clangd", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "clangd" then return end
          require "clangd_extensions"
          vim.keymap.set("n", "<Leader>lw", function() switch_source_header(args.buf) end, {
            buffer = args.buf,
            desc = "Switch source/header file",
          })
        end,
      })
    end,
    opts = {},
  },

  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
}
