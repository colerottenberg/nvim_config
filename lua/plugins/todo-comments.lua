-- Highlight and navigate TODO/FIXME/etc. comments.

require("todo-comments").setup {}

vim.keymap.set("n", "]T", function() require("todo-comments").jump_next() end, { desc = "Next TODO comment" })
vim.keymap.set("n", "[T", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO comment" })
vim.keymap.set("n", "<Leader>fT", "<Cmd>TodoTelescope<CR>", { desc = "Find TODOs" })
