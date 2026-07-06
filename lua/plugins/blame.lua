-- Full-window git blame view.

require("blame").setup {}
vim.keymap.set("n", "<Leader>gB", "<Cmd>BlameToggle<CR>", { desc = "Toggle git blame" })
