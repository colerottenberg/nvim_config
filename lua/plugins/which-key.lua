-- which-key: keymap hints + <Leader> group names.

local wk = require "which-key"

wk.setup {
  icons = { group = "", rules = false, separator = "-" },
}

-- Group / prefix labels (mirrors AstroNvim's `_map_sections`).
wk.add {
  { "<Leader>b", group = "Buffers" },
  { "<Leader>bs", group = "Sort Buffers" },
  { "<Leader>d", group = "Debugger" },
  { "<Leader>f", group = "Find" },
  { "<Leader>g", group = "Git" },
  { "<Leader>j", group = "Jujutsu" },
  { "<Leader>l", group = "Language Tools" },
  { "<Leader>ly", group = "Type Hierarchy" },
  { "<Leader>M", group = "Overseer" },
  { "<Leader>p", group = "Packages" },
  { "<Leader>S", group = "Session" },
  { "<Leader>t", group = "Terminal" },
  { "<Leader>u", group = "UI/UX" },
  { "<Leader>x", group = "Quickfix/Lists" },
  { "ga", group = "Call Hierarchy" },
}
