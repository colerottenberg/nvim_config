-- Transparent background toggle. State persists across sessions (plugin cache).

return {
  'xiyaowong/transparent.nvim',
  lazy = false,
  cond = not vim.g.vscode,
  keys = {
    { '<Leader>ut', '<Cmd>TransparentToggle<CR>', desc = 'Toggle transparency' },
  },
  opts = {
    extra_groups = {
      'NormalFloat',
      'NvimTreeNormal',
      'LspInlayHint',
      'WinBar',
      'WinBarNC',
      'TabLine',
      'TabLineFill',
      'TabLineSel',
      'FloatBorder',
      'FloatTitle',
      'RenderMarkdownCode',
      'LightBulbVirtualText',
      'NeoTree',
      'BufferLine',
      'lualine_c_normal', -- Center fill area background (Normal mode)
      'lualine_c_insert', -- Center fill area background (Insert mode)
      'lualine_c_visual', -- Center fill area background (Visual mode)
      'lualine_c_replace', -- Center fill area background (Replace mode)
      'lualine_c_command', -- Center fill area background (Command mode)
      'lualine_c_inactive', -- Center fill area background (When window lost focus)
    },
    exclude_groups = {
      'lualine_a',
      'lualine_b',
      'lualine_y',
      'lualine_z',
    },
  },
  config = function(_, opts)
    local transparent = require('transparent')
    transparent.setup(opts)
  end,
}
