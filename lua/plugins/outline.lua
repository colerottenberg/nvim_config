-- Symbols outline.

---@type LazySpec
return {
  'hedyhli/outline.nvim',
  lazy = true,
  cmd = { 'Outline', 'OutlineOpen' },
  keys = { -- Example mapping to toggle outline
    {
      '<leader>lS',
      function()
        require('outline').toggle_outline({ focus_outline = true })
      end,
      desc = 'Toggle outline',
    },
  },
  ---@type outline.SetupOpts
  opts = {
    outline_window = {
      position = 'right',
      auto_close = true,
    },
  },

  config = function(_, opts)
    local outline = require('outline')
    outline.setup(opts)
  end,
}
