-- Diagnostics configuration.
--
-- Mirrors the old AstroCore `diagnostics` + `features.diagnostics` settings
-- (from `lua/plugins/astrocore.lua`): virtual_text on, virtual_lines off,
-- underline on, update while typing.

vim.diagnostic.config {
  virtual_text = true,
  virtual_lines = false,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
}
