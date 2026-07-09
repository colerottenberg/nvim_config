-- Transparent background toggle. State persists across sessions (plugin cache).

return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  cond = not vim.g.vscode,
  keys = {
    { "<Leader>uT", "<Cmd>TransparentToggle<CR>", desc = "Toggle transparency" },
  },
  opts = {
    extra_groups = {
      "NormalFloat",
      "NvimTreeNormal",
      "LspInlayHint",
      "WinBar",
      "WinBarNC",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "FloatBorder",
      "FloatTitle",
      "RenderMarkdownCode",
    },
  },
  config = function(_, opts)
    local transparent = require "transparent"
    transparent.setup(opts)
    transparent.clear_prefix "BufferLine"
    transparent.clear_prefix "NeoTree"
    transparent.clear_prefix "lualine"
  end,
}
