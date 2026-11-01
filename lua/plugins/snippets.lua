-- Snippet engine. friendly-snippets are lazy-loaded from vscode/snipmate/lua.

return {
  'L3MON4D3/LuaSnip',
  lazy = true,
  build = vim.fn.has('win32') == 0 and 'make install_jsregexp' or nil,
  dependencies = { 'rafamadriz/friendly-snippets', 'honza/vim-snippets' },
  keys = {
    {
      '<C-l>',
      mode = { 'i', 's' },
      desc = 'LuaSnip: next choice',
      function()
        local luasnip = require('luasnip')
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end,
    },
    {
      '<C-h>',
      mode = { 'i', 's' },
      desc = 'LuaSnip: previous choice',
      function()
        local luasnip = require('luasnip')
        if luasnip.choice_active() then
          luasnip.change_choice(-1)
        end
      end,
    },
  },
  config = function()
    local luasnip = require('luasnip')
    luasnip.config.setup({})
    luasnip.filetype_extend('javascript', { 'javascriptreact' })
    luasnip.filetype_extend('c', { 'cdoc' })
    luasnip.filetype_extend('cpp', { 'cppdoc' })
    luasnip.filetype_extend('python', { 'pydoc' })
    luasnip.filetype_extend('lua', { 'luadoc' })
    luasnip.filetype_extend('sh', { 'zsh' })
    luasnip.filetype_extend('sh', { 'bash' })
    luasnip.filetype_extend('opencode', { 'markdown' })
    for _, loader in ipairs({ 'vscode', 'snipmate', 'lua' }) do
      require('luasnip.loaders.from_' .. loader).lazy_load()
    end
  end,
}
