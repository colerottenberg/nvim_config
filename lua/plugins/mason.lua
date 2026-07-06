-- Mason: LSP/DAP/tool installer.
--
-- mason-lspconfig `automatic_enable` calls vim.lsp.enable for every installed
-- server (server-specific settings come from vim.lsp.config, see config/lsp.lua
-- and the lang modules). rust_analyzer and jdtls are excluded because
-- rustaceanvim and nvim-java own them.

require("mason").setup {}

require("mason-lspconfig").setup {
  automatic_enable = {
    exclude = { "rust_analyzer", "jdtls" },
  },
}

require("mason-tool-installer").setup {
  ensure_installed = {
    -- language servers
    "lua-language-server",
    -- "clangd",
    -- "taplo",
    -- "marksman",
    -- formatters / linters
    "stylua",
    -- debuggers
    -- "codelldb",
    -- misc tooling
    "tree-sitter-cli",
  },
}
