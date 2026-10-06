local add_sign = { text = '▍' }
local change_sign = { text = '▍' }
local delete_sign = { text = '▍' }
local top_delete_sign = { text = '▍' }
local change_delete_sign = { text = '▍' }
local untracked_sign = { text = '▍' }

local diff_commit = function()
  require('snacks.picker').git_log({
    focus = 'list',
    confirm = function(picker, item)
      picker:close()
      local commit_sha = item.commit
      if not commit_sha then
        vim.notify('No commit hash found', vim.log.levels.WARN)
        return
      end

      require('gitsigns').diffthis(commit_sha)
    end,
  })
end

---@type LazySpec
return {
  -- Git signs + per-buffer git hunk mappings.

  ---@type LazySpec
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      {
        '<Leader>gP',
        function()
          require('gitsigns').preview_hunk()
        end,
        desc = 'Preview hunk',
      },
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
          require('gitsigns').blame_line({ full = true })
        end,
        desc = 'View full git blame',
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
          require('gitsigns').diffthis()
        end,
        desc = 'View git diff',
      },
      {
        '<Leader>gd',
        diff_commit,
        desc = 'View git diff a commit',
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
    },
    dependencies = { 'folke/snacks.nvim' },
  },
  ---@type LazySpec
  {
    'NeogitOrg/neogit',
    lazy = true,
    dependencies = {
      'esmuellert/codediff.nvim',
      'folke/snacks.nvim',
    },
    cmd = 'Neogit',
    keys = {
      { '<leader>gn', '<cmd>Neogit<cr>', desc = 'Show Neogit UI' },
    },
  },
}
