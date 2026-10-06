---@type LazySpec
return {
  'sudo-tee/opencode.nvim',
  ---@type OpencodeConfig
  opts = {
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
      input_window = {
        ['<leader>om'] = { 'switch_mode' }, -- Switch between modes (build/plan)
        ['<leader>or'] = { 'cycle_variant' }, -- Switch between modes (build/plan)
      },
    },
    ui = {
      input = {
        min_height = 0.30,
        max_height = 0.40,
        auto_hide = false,
      },
    },
    context = {
      diagnostics = {
        info = true,
        only_closest = false,
      },
      git_diff = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
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
