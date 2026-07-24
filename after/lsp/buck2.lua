-- Hand-configured Buck2 LSP: overrides nvim-lspconfig's bundled lsp/buck2.lua.
-- No Mason package backs this -- `buck2` itself IS the language server via
-- its `lsp` subcommand, so it's enabled explicitly (config/lsp.lua) rather
-- than through mason-lspconfig's automatic_enable. See
-- docs/adding-a-language-server.md.
return {
  cmd = { 'buck2', 'lsp' },
  filetypes = { 'bzl' },
  root_markers = { '.buckconfig', '.git' },
}
