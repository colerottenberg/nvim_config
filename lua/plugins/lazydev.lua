-- Lua LS enrichment for Neovim config editing. The blink source is registered
-- in plugins/blink.lua.

return {
  'folke/lazydev.nvim',
  ft = 'lua',
  cmd = 'LazyDev',
  opts = {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = 'lazy.nvim', words = { 'Lazy' } },
      { path = 'snacks.nvim', words = { 'Snacks' } },
      { path = 'lazydev.nvim', words = { 'LazyDev' } },
    },
  },
}
