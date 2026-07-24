-- Git signs + per-buffer git hunk mappings.

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

return {
  'lewis6991/gitsigns.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  cond = vim.fn.executable('git') == 1,
  keys = {
    {
      '<Leader>gP',
      function()
        require('gitsigns').preview_hunk()
      end,
      desc = 'Preview hunk',
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
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map('n', ']g', function()
        gs.nav_hunk('next')
      end, 'Next hunk')
      map('n', '[g', function()
        gs.nav_hunk('prev')
      end, 'Previous hunk')
      map('n', ']G', function()
        gs.nav_hunk('last')
      end, 'Last hunk')
      map('n', '[G', function()
        gs.nav_hunk('first')
      end, 'First hunk')
      map('n', '<Leader>gl', function()
        gs.blame_line()
      end, 'View git blame')
      map('n', '<Leader>gL', function()
        gs.blame_line({ full = true })
      end, 'View full git blame')
      map('n', '<Leader>gp', function()
        gs.preview_hunk_inline()
      end, 'Preview git hunk')
      map('n', '<Leader>gr', function()
        gs.reset_hunk()
      end, 'Reset git hunk')
      map('v', '<Leader>gr', function()
        gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, 'Reset git hunk')
      map('n', '<Leader>gR', function()
        gs.reset_buffer()
      end, 'Reset git buffer')
      map('n', '<Leader>gs', function()
        gs.stage_hunk()
      end, 'Stage git hunk')
      map('v', '<Leader>gs', function()
        gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
      end, 'Stage git hunk')
      map('n', '<Leader>gS', function()
        gs.stage_buffer()
      end, 'Stage git buffer')
      map('n', '<Leader>gd', function()
        gs.diffthis()
      end, 'View git diff')
      map('n', '<Leader>gD', diff_commit, 'View git diff a commit')
      map('n', '<Leader>gh', function()
        gs.diffthis('~1')
      end, 'Git diff ~1')
      map({ 'o', 'x' }, 'ig', gs.select_hunk, 'Select git hunk')
    end,
  },
  dependencies = { 'folke/snacks.nvim' },
}
