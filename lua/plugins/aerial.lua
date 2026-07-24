-- Symbols outline.

return {
  'stevearc/aerial.nvim',
  cmd = { 'AerialToggle', 'AerialOpen', 'AerialNavToggle' },
  keys = {
    {
      '<Leader>lS',
      function()
        require('aerial').snacks_picker({ focus = 'list', layout = 'right' })
      end,
      desc = 'Symbols outline',
    },
    {
      '<Leader>ln',
      function()
        require('aerial').nav_toggle()
      end,
      desc = 'Symbols navigation',
    },
  },
  opts = {
    attach_mode = 'global',
    backends = { 'lsp', 'treesitter', 'markdown', 'man' },
    layout = { min_width = 28 },
    show_guides = true,
    filter_kind = false,
    nerd_font = 'auto',
    guides = { mid_item = '├ ', last_item = '└ ', nested_top = '│ ', whitespace = '  ' },
    keymaps = {
      ['[y'] = 'actions.prev',
      [']y'] = 'actions.next',
      ['[Y'] = 'actions.prev_up',
      [']Y'] = 'actions.next_up',
      ['{'] = false,
      ['}'] = false,
      ['[['] = false,
      [']]'] = false,
    },
    on_attach = function(bufnr)
      vim.keymap.set('n', '[y', '<Cmd>AerialPrev<CR>', { buffer = bufnr, desc = 'Previous symbol' })
      vim.keymap.set('n', ']y', '<Cmd>AerialNext<CR>', { buffer = bufnr, desc = 'Next symbol' })
    end,
  },
  dependencies = {
    'onsails/lspkind.nvim',
  },
}
