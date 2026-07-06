-- Jujutsu (jj) integration.

require("jj").setup {}

local map = vim.keymap.set
map("n", "<Leader>jd", "<Cmd>Jdiff<CR>", { desc = "Jujutsu diff" })
map("n", "<Leader>jl", function() require("jj.cmd").log() end, { desc = "Jujutsu log" })
map("n", "<Leader>jD", function() require("jj.cmd").describe() end, { desc = "Jujutsu describe" })
map("n", "<Leader>je", function() require("jj.cmd").edit() end, { desc = "Jujutsu edit" })
map("n", "<Leader>js", function() require("jj.cmd").status() end, { desc = "Jujutsu status" })
map("n", "<Leader>jf", function() require("jj.cmd").split() end, { desc = "Jujutsu split" })
