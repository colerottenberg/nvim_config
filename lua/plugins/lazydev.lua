-- Lua LS enrichment for Neovim config editing. The blink source is registered
-- in plugins/blink.lua.

require("lazydev").setup {
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim", words = { "Snacks" } },
    { path = "lazydev.nvim", words = { "LazyDev" } },
  },
}
