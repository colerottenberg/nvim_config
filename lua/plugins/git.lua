local add_sign = { text = '▍' }
local change_sign = { text = '▍' }
local delete_sign = { text = '▍' }
local top_delete_sign = { text = '▍' }
local change_delete_sign = { text = '▍' }
local untracked_sign = { text = '▍' }

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
        '<Leader>gl',
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
    opts = {
      signs = {
        add = add_sign,
        change = change_sign,
        delete = delete_sign,
        topdelete = top_delete_sign,
        changedelete = change_delete_sign,
        untracked = untracked_sign,
      },
      signs_staged = {
        add = add_sign,
        change = change_sign,
        delete = delete_sign,
        topdelete = top_delete_sign,
        changedelete = change_delete_sign,
        untracked = untracked_sign,
      },
      word_diff = true,
    },
    dependencies = { 'folke/snacks.nvim' },
  },
  ---@type LazySpec
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose' },
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
}
