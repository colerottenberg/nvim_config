-- LSP: nvim-lspconfig (server definitions) + mason stack (installs) + the
-- hand-written engine in config/lsp.lua (on-attach mappings, format-on-save,
-- feature toggles, server enablement).

return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp', -- capabilities merged by config/lsp.lua
    },
    config = function()
      require('mason-lspconfig').setup({
        automatic_enable = {
          exclude = {
            -- rust_analyzer is owned by rustaceanvim, jdtls by nvim-java.
            'rust_analyzer',
            'jdtls',
          },
        },
      })
      require('mason-tool-installer').setup({
        ensure_installed = {
          -- language servers
          'lua-language-server',
          -- formatters / linters
          'stylua',
          -- misc tooling
          'tree-sitter-cli',
        },
      })
      require('config.lsp')
    end,
  },
}
