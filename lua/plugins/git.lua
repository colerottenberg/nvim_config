local dv = function(args)
  require('diffview').open(args)
end

---@type fun(range:number[]?, args:string[])
local dv_fh = function(range, args)
  require('diffview').file_history(range, args)
end

---@type table<string, snacks.picker.Action.spec>
local dv_actions = {
  -- Copy the selected commit hash to the system clipboard.
  copy_commit = function(_, item)
    if not item or not item.commit then
      vim.notify('No commit selected', vim.log.levels.WARN)
      return
    end

    vim.fn.setreg('+', item.commit)
    vim.notify('Copied commit: ' .. item.commit)
  end,

  -- working tree vs. highlighted commit
  dv_worktree = function(picker, item)
    if not item then
      return
    end
    picker:close()
    dv({ item.commit })
  end,

  -- only the changes introduced by the highlighted commit
  dv_commit = function(picker, item)
    if not item then
      return
    end
    picker:close()
    dv({ item.commit .. '^!' })
  end,

  -- range between two multi-selected commits (Tab to select)
  dv_range = function(picker)
    local sel = picker:selected({ fallback = false })
    if #sel ~= 2 then
      vim.notify('Select exactly two commits (<Tab>)', vim.log.levels.WARN)
      return
    end
    -- git_log lists newest first, so the higher idx is the older commit
    table.sort(sel, function(a, b)
      return a.idx > b.idx
    end)
    picker:close()
    dv({ sel[1].commit .. '^..' .. sel[2].commit })
  end,

  -- same range, but against the merge base (three-dot)
  dv_range_base = function(picker)
    local sel = picker:selected({ fallback = false })
    if #sel ~= 2 then
      vim.notify('Select exactly two commits (<Tab>)', vim.log.levels.WARN)
      return
    end
    table.sort(sel, function(a, b)
      return a.idx > b.idx
    end)
    picker:close()
    dv({ sel[1].commit .. '...' .. sel[2].commit })
  end,
}
local dv_keys = {
  ['y'] = { 'copy_commit', mode = 'n', desc = 'Copy commit hash' },
  ['<a-d>'] = { 'dv_worktree', mode = { 'n', 'i' } },
  ['<a-c>'] = { 'dv_commit', mode = { 'n', 'i' } },
  ['<a-r>'] = { 'dv_range', mode = { 'n', 'i' } },
  ['<a-b>'] = { 'dv_range_base', mode = { 'n', 'i' } },
}

-- detached HEAD entries have no branch name, so fall back to the commit
local function branch_ref(item)
  return item.branch or item.commit
end

local function two_branches(picker)
  local sel = picker:selected({ fallback = false })
  if #sel ~= 2 then
    vim.notify('Select exactly two branches (<Tab>)', vim.log.levels.WARN)
    return
  end
  return branch_ref(sel[1]), branch_ref(sel[2])
end

---@type table<string, snacks.picker.Action.spec>
local dv_branch_actions = {
  -- working tree vs. highlighted branch
  dv_branch_worktree = function(picker, item)
    if not item then
      return
    end
    picker:close()
    dv({ branch_ref(item) })
  end,

  -- what the highlighted branch adds since it diverged from HEAD (PR-style)
  dv_branch_base = function(picker, item)
    if not item then
      return
    end
    picker:close()
    dv({ 'HEAD...' .. branch_ref(item) })
  end,

  -- direct diff between two multi-selected branches (Tab to select)
  dv_branch_range = function(picker)
    local a, b = two_branches(picker)
    if not a then
      return
    end
    picker:close()
    dv({ a .. '..' .. b })
  end,

  -- two selected branches, against their merge base (three-dot)
  dv_branch_range_base = function(picker)
    local a, b = two_branches(picker)
    if not a then
      return
    end
    picker:close()
    dv({ a .. '...' .. b })
  end,

  -- commit history of the highlighted branch
  dv_branch_history = function(picker, item)
    if not item then
      return
    end
    picker:close()
    vim.cmd('DiffviewFileHistory --range=' .. branch_ref(item))
  end,
}
local dv_branch_keys = {
  ['<a-d>'] = { 'dv_branch_worktree', mode = { 'n', 'i' } },
  ['<a-m>'] = { 'dv_branch_base', mode = { 'n', 'i' } },
  ['<a-r>'] = { 'dv_branch_range', mode = { 'n', 'i' } },
  ['<a-b>'] = { 'dv_branch_range_base', mode = { 'n', 'i' } },
  ['<a-l>'] = { 'dv_branch_history', mode = { 'n', 'i' } },
}
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
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    dependencies = { 'folke/snacks.nvim' },
    ---@type LazyKeysSpec[]
    keys = {
      {
        '<leader>gl',
        function()
          require('snacks').picker.git_log({
            actions = dv_actions,
            win = {
              input = { keys = dv_keys },
              list = { keys = dv_keys },
            },
          })
        end,
        desc = 'Git Log',
      },
      {
        '<leader>gc',
        function()
          require('snacks').picker.git_log({
            current_file = true,
            actions = dv_actions,
            win = {
              input = { keys = dv_keys },
              list = { keys = dv_keys },
            },
          })
        end,
        desc = 'Git Log (File)',
      },
      {
        '<leader>gD',
        function()
          require('snacks').picker.git_diff()
        end,
        desc = 'Git diff by file',
      },
      {
        '<leader>gb',
        function()
          require('snacks').picker.git_branches({
            all = true,
            actions = dv_branch_actions,
            win = { input = { keys = dv_branch_keys } },
          })
        end,
        desc = 'Git Branches',
      },
      {
        '<leader>gf',
        function()
          require('snacks').picker.git_files({
            title = 'Git File History',
            confirm = function(self, item, action)
              self:close()
              if not item then
                return
              end
              dv_fh(nil, { item.file })
            end,
          })
        end,
        desc = 'Git File History',
      },
      {
        '<leader>gf',
        function()
          local filepath = vim.api.nvim_buf_get_name(0)
          local start_line = vim.fn.line('v')
          local end_line = vim.fn.line('.')
          -- Flip starting and ending if reversed
          if start_line > end_line then
            start_line, end_line = end_line, start_line
          end
          dv_fh({ start_line, end_line }, { filepath })
        end,
        desc = 'Git File History',
        mode = { 'x' },
      },
    },
    ---@type DiffviewConfig
    opts = {
      keymaps = {
        view = {
          {
            'n',
            'q',
            function()
              require('diffview').close()
            end,
            { desc = 'Close Diffview' },
          },
          {
            'n',
            '<leader>e',
            '<cmd>DiffviewToggleFiles<cr>',
            { desc = 'Toggle the file panel' },
          },
          {
            'n',
            '<leader>b',
            '<cmd>DiffviewFocusFiles<cr>',
            { desc = 'Bring focus to the file panel' },
          },
        },
        file_panel = {
          {
            'n',
            'q',
            function()
              require('diffview').close()
            end,
            { desc = 'Close Diffview' },
          },
          {
            'n',
            '<leader>e',
            '<cmd>DiffviewToggleFiles<cr>',
            { desc = 'Toggle the file panel' },
          },
          {
            'n',
            '<leader>b',
            '<cmd>DiffviewFocusFiles<cr>',
            { desc = 'Bring focus to the file panel' },
          },
        },
        file_history_panel = {
          {
            'n',
            'q',
            function()
              require('diffview').close()
            end,
            { desc = 'Close Diffview' },
          },
          {
            'n',
            '<leader>e',
            '<cmd>DiffviewToggleFiles<cr>',
            { desc = 'Toggle the file panel' },
          },
          {
            'n',
            '<leader>b',
            '<cmd>DiffviewFocusFiles<cr>',
            { desc = 'Bring focus to the file panel' },
          },
        },
      },
    },
  },
  ---@type LazySpec
  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    opts = {},
  },
}
