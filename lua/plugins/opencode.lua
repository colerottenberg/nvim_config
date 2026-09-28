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
