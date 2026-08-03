return {
  'kawre/leetcode.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'folke/snacks.nvim',
  },
  opts = {},
  cmd = { 'Leet' },
  keys = {
    { '<Leader>Lm', vim.cmd.Leet, desc = 'Leetcode Menu' },
    {
      '<Leader>Lc',
      function()
        local lc = require('leetcode.command')
        lc.change_lang()
      end,
      desc = 'change language',
    },
    {
      '<Leader>Ls',
      function()
        local lc = require('leetcode.command')
        lc.q_submit()
      end,
      desc = 'submit',
    },
    {
      '<Leader>Lr',
      function()
        local lc = require('leetcode.command')
        lc.q_run()
      end,
      desc = 'run test cases',
    },
    {
      '<Leader>Lh',
      function()
        local lc = require('leetcode.command')
        lc.hints()
      end,
      desc = 'hints',
    },
    {
      '<Leader>Lp',
      function()
        local lc = require('leetcode.command')
        lc.desc_toggle()
      end,
      desc = 'toggle description',
    },
    {
      '<Leader>Le',
      function()
        local lc = require('leetcode.command')
        lc.exit()
      end,
      desc = 'exit',
    },
  },
}
