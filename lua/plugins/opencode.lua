---@type LazySpec
return {
  'sudo-tee/opencode.nvim',
  branch = 'v2', -- Use the v2 branch for testing with OpenCode v2
  config = function()
    ---@type OpencodeConfig
    local opts = {
      preferred_picker = 'snacks',
      preferred_completion = 'blink',
      default_mode = 'plan',
      keymap = {
        session_picker = {
          rename_session = { '<C-r>', mode = { 'i', 'n' } },
          delete_session = { '<C-d>', mode = { 'i', 'n' } },
          new_session = { '<C-n>', mode = { 'i', 'n' } },
          fork_session = { '<C-f>', mode = { 'i', 'n' } },
          open_in_tab = { '<C-t>', mode = { 'i', 'n' } },
          toggle_scope = { '<C-g>', mode = { 'i', 'n' } },
        },
      },
      ui = {
        input = {
          min_height = 0.30,
          max_height = 0.40,
        },
      },
    }
    require('opencode').setup(opts)
  end,
  dependencies = {
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'markdown', 'opencode_output' },
      },
      ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
    },
    'saghen/blink.cmp',
    'folke/snacks.nvim',
  },
}
