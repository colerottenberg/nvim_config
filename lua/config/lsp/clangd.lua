-- Keep clangd's executable selection PATH-based. This allows a shell profile
-- (for example, a PowerShell Vitis function) to select a vendor clangd without
-- changing the LSP configuration.
---@type vim.lsp.Config
return {
  cmd = { 'clangd' },
}
