-- Full-window git blame view.

return {
  "FabijanZulj/blame.nvim",
  cmd = "BlameToggle",
  cond = not vim.g.vscode,
  keys = {
    { "<Leader>gB", "<Cmd>BlameToggle<CR>", desc = "Toggle git blame" },
  },
  opts = {},
}
