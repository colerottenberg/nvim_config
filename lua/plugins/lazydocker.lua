-- LazyDocker TUI in a floating terminal.

pcall(function() require("lazydocker").setup {} end)

vim.keymap.set("n", "<Leader>td", function() require("lazydocker").open() end, { desc = "ToggleTerm LazyDocker" })
