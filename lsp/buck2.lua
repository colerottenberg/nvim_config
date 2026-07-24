-- ~/.config/nvim/lsp/buck2.lua
---@type vim.lsp.Config
return {
  cmd = { 'buck2', 'lsp' },
  filetypes = { 'bzl' },
  root_markers = { '.buckconfig' },
}
