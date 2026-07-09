-- LazyDocker TUI in a floating terminal.

return {
  "mgierada/lazydocker.nvim",
  dependencies = { "akinsho/toggleterm.nvim" },
  keys = {
    { "<Leader>td", function() require("lazydocker").open() end, desc = "ToggleTerm LazyDocker" },
  },
  opts = {},
}
