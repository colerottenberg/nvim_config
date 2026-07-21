-- Highlight and navigate TODO/FIXME/etc. comments.

return {
  "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TodoQuickFix", "TodoLocList", "TodoTelescope" },
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "]T", function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
    { "[T", function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" },
  },
  opts = {},
}
