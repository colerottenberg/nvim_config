return {
  'kawre/leetcode.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'folke/snacks.nvim',
  },
  opts = {
    -- configuration goes here
  },
  keys = {
    { '<Leader>L', vim.cmd.Leet, desc = 'Leetcode Menu' },
  },
}
