-- Signature help as you type.

return {
  "ray-x/lsp_signature.nvim",
  event = "VeryLazy",
  cond = not vim.g.vscode,
  opts = {
    bind = true,
    handler_opts = { border = "rounded" },
    hint_enable = true,
    hint_prefix = "🐼 ",
  },
}
