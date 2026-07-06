-- Split navigation + resizing (seamless with tmux/wezterm/kitty).

local ss = require "smart-splits"

ss.setup {
  ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
  ignored_buftypes = { "nofile" },
}

local map = vim.keymap.set
map("n", "<C-H>", ss.move_cursor_left, { desc = "Move to left split" })
map("n", "<C-J>", ss.move_cursor_down, { desc = "Move to below split" })
map("n", "<C-K>", ss.move_cursor_up, { desc = "Move to above split" })
map("n", "<C-L>", ss.move_cursor_right, { desc = "Move to right split" })
map("n", "<C-Up>", ss.resize_up, { desc = "Resize split up" })
map("n", "<C-Down>", ss.resize_down, { desc = "Resize split down" })
map("n", "<C-Left>", ss.resize_left, { desc = "Resize split left" })
map("n", "<C-Right>", ss.resize_right, { desc = "Resize split right" })
