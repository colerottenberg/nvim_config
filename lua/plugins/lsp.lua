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
            -- buck2 is hand-configured (after/lsp/buck2.lua, enabled in
            -- config/lsp.lua) since it has no Mason package; exclude the
            -- Mason-known Bazel/Starlark servers so none of them can also
            -- attach to .bzl buffers if one is ever installed.
            'starlark_rust',
            'starpls',
            'bzl',
            'bazelrc_lsp',
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

  -- Standalone entry so :Mason (<Leader>pm) works before any file is opened.
  { 'mason-org/mason.nvim', cmd = 'Mason', opts = {} },
}
