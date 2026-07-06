-- Transparent background toggle. State persists across sessions (plugin cache).

require("transparent").setup {
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
}

local transparent = require "transparent"
transparent.clear_prefix "BufferLine"
transparent.clear_prefix "NeoTree"
transparent.clear_prefix "lualine"

vim.keymap.set("n", "<Leader>uT", "<Cmd>TransparentToggle<CR>", { desc = "Toggle transparency" })
