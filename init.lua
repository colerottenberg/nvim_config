-- Standalone Neovim configuration (vim.pack).
-- Migrated from an AstroNvim (lazy.nvim) config -- see docs/ and git history.
--
-- Leader keys MUST be set before any plugin or mapping is defined.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Install and register every plugin (blocks on first-run install).
require "bootstrap"

-- Core editor configuration.
require "config.options"
require "config.diagnostics"
require "config.autocmds"
require "config.keymaps"

-- LSP engine (native vim.lsp.config / vim.lsp.enable).
require "config.lsp"

-- VS Code (vscode-neovim) specific overrides, no-op outside VS Code.
require "config.vscode"

-- Plugin setup. Each module is self-contained: it requires + configures one
-- plugin (or a small related group). Order within the folder does not matter;
-- explicit ordering that does matter (colorscheme, icons) is handled in
-- bootstrap.lua via load order.
for _, module in ipairs {
  -- appearance
  "colorschemes",
  "mini-icons",
  "lualine",
  "bufferline",
  "transparent",
  -- core editing / navigation
  "neo-tree",
  "snacks",
  "which-key",
  "smart-splits",
  "window-picker",
  "toggleterm",
  "aerial",
  "resession",
  "guess-indent",
  "autopairs",
  "highlight-colors",
  "todo-comments",
  "render-markdown",
  -- completion / snippets
  "luasnip",
  "blink",
  "lazydev",
  -- treesitter
  "treesitter",
  -- git / vcs
  "gitsigns",
  "blame",
  "jj",
  -- language tooling
  "mason",
  "lang.rust",
  "lang.cpp",
  "lang.java",
  -- debugging
  "dap",
  -- tasks / tools
  "overseer",
  "lazydocker",
  -- misc / integrations
  "lsp-signature",
  "presence",
  "avante",
} do
  local ok, err = pcall(require, "plugins." .. module)
  if not ok then
    vim.schedule(function() vim.notify(("Error loading plugins.%s:\n%s"):format(module, err), vim.log.levels.ERROR) end)
  end
end
