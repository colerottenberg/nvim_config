-- Snippet engine. friendly-snippets are lazy-loaded from vscode/snipmate/lua.

return {
  'L3MON4D3/LuaSnip',
  lazy = true,
  build = vim.fn.has('win32') == 0 and 'make install_jsregexp' or nil,
  dependencies = { 'rafamadriz/friendly-snippets' },
  opts = {
    history = true,
    delete_check_events = 'TextChanged',
    region_check_events = 'CursorMoved',
  },
  config = function(_, opts)
    local luasnip = require('luasnip')
    luasnip.config.setup(opts)
    luasnip.filetype_extend('javascript', { 'javascriptreact' })
    for _, loader in ipairs({ 'vscode', 'snipmate', 'lua' }) do
      require('luasnip.loaders.from_' .. loader).lazy_load()
    end
  end,
}
