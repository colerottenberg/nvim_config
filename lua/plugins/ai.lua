-- avante.nvim over ACP. Provider picked per machine; see lua/config/ai.lua.

local ai = require('config.ai')

---@module 'avante'
---@type LazySpec
return {
  'avante-corp/avante.nvim',
  build = vim.fn.has('win32') ~= 0 and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
    or 'make',
  event = 'VeryLazy',
  version = false, -- upstream is emphatic: never pin this
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'folke/snacks.nvim',
  },
  ---@type avante.Config
  opts = {
    provider = ai.is('opencode') and 'opencode' or 'claude-code',
    acp_providers = {
      -- Upstream default is `claude-agent-acp`, which isn't published under
      -- that name. The adapter whose env vars it sets is
      -- @zed-industries/claude-code-acp, and its binary is `claude-code-acp`.
      ['claude-code'] = {
        command = 'claude-code-acp',
        env = { ACP_PERMISSION_MODE = 'default' },
      },
      -- opencode's built-in entry (`opencode acp`) is already correct.
    },
    behaviour = {
      -- Both of these default to permissive upstream.
      auto_approve_tool_permissions = false,
      auto_apply_diff_after_generation = false,
    },
    input = { provider = 'snacks' },
  },
}
