-- Standalone Neovim configuration, managed by lazy.nvim.
--
-- Leader keys MUST be set before lazy.nvim and any mapping.
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

if vim.g.vscode then
  require('config.vscode')
else
  -- Core editor configuration (options first so lazy-loaded plugins see them).
  require('config.options')
  require('config.diagnostics')
  require('config.autocmds')
  require('config.keymaps')

  -- LSP engine note: `config.lsp` is loaded from the nvim-lspconfig spec
  -- (lua/plugins/lsp.lua), after mason and blink.cmp are available.

  -- VS Code (vscode-neovim) specific overrides, no-op outside VS Code.
  require('config.vscode')

  -- Plugin manager: installs and lazy-loads everything under lua/plugins/.
  require('config.lazy')
end
