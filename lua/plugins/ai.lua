-- Coding agent in a split. One <Leader>a surface, two backends; see lua/config/ai.lua.

local ai = require('config.ai')

-- Pinned count so <Leader>aa after a count still hits the same terminal
-- (Snacks.terminal keys its windows on cmd + cwd + env + v:count1).
local opencode_term = { count = 1, win = { position = 'right', width = 0.35 } }

local function opencode_ask(context)
  return function()
    require('opencode').ask(context .. ': ')
  end
end

return {
  ---@type LazySpec
  {
    'coder/claudecode.nvim',
    cond = ai.is('claude'),
    dependencies = { 'folke/snacks.nvim' },
    cmd = {
      'ClaudeCode',
      'ClaudeCodeFocus',
      'ClaudeCodeAdd',
      'ClaudeCodeSend',
      'ClaudeCodeTreeAdd',
      'ClaudeCodeSelectModel',
      'ClaudeCodeStatus',
      'ClaudeCodeDiffAccept',
      'ClaudeCodeDiffDeny',
    },
    opts = {
      terminal = {
        provider = 'snacks',
        split_side = 'right',
        split_width_percentage = 0.35,
      },
      diff_opts = { layout = 'vertical' },
    },
    keys = {
      { '<Leader>aa', '<Cmd>ClaudeCode<CR>', desc = 'Toggle agent' },
      { '<Leader>af', '<Cmd>ClaudeCodeFocus<CR>', desc = 'Focus agent' },
      { '<Leader>as', '<Cmd>ClaudeCodeAdd %<CR>', desc = 'Send to agent' },
      { '<Leader>as', '<Cmd>ClaudeCodeSend<CR>', mode = 'x', desc = 'Send selection to agent' },
      { '<Leader>ab', '<Cmd>ClaudeCodeAdd %<CR>', desc = 'Add buffer to context' },
      { '<Leader>at', '<Cmd>ClaudeCodeTreeAdd<CR>', ft = 'neo-tree', desc = 'Add tree selection' },
      { '<Leader>ar', '<Cmd>ClaudeCode --resume<CR>', desc = 'Resume session' },
      { '<Leader>aC', '<Cmd>ClaudeCode --continue<CR>', desc = 'Continue last session' },
      { '<Leader>am', '<Cmd>ClaudeCodeSelectModel<CR>', desc = 'Select model' },
      { '<Leader>ay', '<Cmd>ClaudeCodeDiffAccept<CR>', desc = 'Accept diff' },
      { '<Leader>aD', '<Cmd>ClaudeCodeDiffDeny<CR>', desc = 'Reject diff' },
    },
  },

  ---@type LazySpec
  {
    'NickvanDyke/opencode.nvim',
    cond = ai.is('opencode'),
    dependencies = { 'folke/snacks.nvim' },
    -- Config is read from a global at require-time, so it must be set in `init`.
    init = function()
      vim.g.opencode_opts = {
        server = {
          -- Upstream default is a bare `vsplit term://opencode`, which has no
          -- toggle. Route it through snacks so <Leader>aa owns the same window.
          start = function()
            Snacks.terminal.get('opencode', opencode_term)
          end,
        },
      }
    end,
    keys = {
      {
        '<Leader>aa',
        function()
          Snacks.terminal.toggle('opencode', opencode_term)
        end,
        desc = 'Toggle agent',
      },
      {
        '<Leader>af',
        function()
          Snacks.terminal.focus('opencode', opencode_term)
        end,
        desc = 'Focus agent',
      },
      { '<Leader>as', opencode_ask('@this'), mode = { 'n', 'x' }, desc = 'Send to agent' },
      { '<Leader>ab', opencode_ask('@buffer'), desc = 'Add buffer to context' },
      { '<Leader>ax', opencode_ask('@diagnostics'), desc = 'Send diagnostics' },
      {
        '<Leader>ap',
        function()
          require('opencode').select()
        end,
        mode = { 'n', 'x' },
        desc = 'Prompt picker',
      },
    },
  },
}
