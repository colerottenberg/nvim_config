---@type LazySpec
return {
  -- Git signs + per-buffer git hunk mappings.

  ---@type LazySpec
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {

      -- Navigation mappings
      {
        ']g',
        function()
          require('gitsigns').nav_hunk('next')
        end,
        desc = 'Next hunk',
      },
      {
        '[g',
        function()
          require('gitsigns').nav_hunk('prev')
        end,
        desc = 'Previous hunk',
      },
      {
        ']G',
        function()
          require('gitsigns').nav_hunk('last')
        end,
        desc = 'Last hunk',
      },
      {
        '[G',
        function()
          require('gitsigns').nav_hunk('first')
        end,
        desc = 'First hunk',
      },
      -- Leader-based mappings
      {
        '<Leader>gb',
        function()
          require('gitsigns').toggle_current_line_blame()
        end,
        desc = 'Toggle line blame',
      },
      {
        '<Leader>gL',
        function()
          require('gitsigns').blame()
        end,
        desc = 'View full blame',
      },
      {
        '<Leader>gp',
        function()
          require('gitsigns').preview_hunk_inline()
        end,
        desc = 'Preview git hunk',
      },
      {
        '<Leader>gr',
        function()
          require('gitsigns').reset_hunk()
        end,
        desc = 'Reset git hunk',
      },
      {
        '<Leader>gR',
        function()
          require('gitsigns').reset_buffer()
        end,
        desc = 'Reset git buffer',
      },
      {
        '<Leader>gs',
        function()
          require('gitsigns').stage_hunk()
        end,
        desc = 'Stage git hunk',
      },
      {
        '<Leader>gS',
        function()
          require('gitsigns').stage_buffer()
        end,
        desc = 'Stage git buffer',
      },
      {
        '<Leader>gd',
        function()
          require('gitsigns').diffthis(nil, { unified = true })
        end,
        desc = 'View git diff',
      },
      {
        '<Leader>gq',
        function()
          require('gitsigns').setqflist('attached', { open = false }, function(err)
            if err == nil then
              vim.notify('Added Git Hunks to Quickfix List', vim.log.levels.INFO)
            else
              vim.notify(err, vim.log.levels.ERROR)
            end
          end)
        end,
        desc = 'Add Buffer Git Hunks to qflist',
      },

      -- Visual mode mappings
      {
        '<Leader>gr',
        function()
          require('gitsigns').reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end,
        mode = 'v',
        desc = 'Reset git hunk',
      },
      {
        '<Leader>gs',
        function()
          require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end,
        mode = 'v',
        desc = 'Stage git hunk',
      },
      -- Operator/visual mode mappings
      {
        'ag',
        function()
          require('gitsigns').select_hunk()
        end,
        mode = { 'o', 'x' },
        desc = 'Select git hunk',
      },
    },
    ---@type Gitsigns.Config
    opts = {},
    dependencies = { 'folke/snacks.nvim' },
  },
  ---@type LazySpec
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose' },
    dependencies = { 'folke/snacks.nvim' },
    ---@type LazyKeysSpec[]
    keys = {
      {
        '<leader>gD',
        function()
          require('diffview').open()
        end,
        desc = 'Diff working tree',
      },
    },
    ---@type DiffviewConfig
    opts = {
      keymaps = {
        file_panel = {
          {
            'n',
            'q',
            function()
              require('diffview').close()
            end,
            { desc = 'Close Diffview' },
          },
        },
      },
    },
  },
  ---@type LazySpec
  {
    'NeogitOrg/neogit',
    lazy = true,
    dependencies = {
      'sindrets/diffview.nvim',
      'folke/snacks.nvim',
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>gn', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
    },
  },
  ---@type LazySpec
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    opts = {},
  },
}
