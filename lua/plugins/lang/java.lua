-- Java: nvim-java sets up and drives jdtls. Must run before jdtls is enabled.

require("java").setup()
vim.lsp.enable "jdtls"
