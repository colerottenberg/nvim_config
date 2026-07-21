-- Pretty in-buffer markdown rendering.

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = "markdown",
  cmd = "RenderMarkdown",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<Leader>um", "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown rendering" },
  },
  opts = {
    file_types = { "markdown" },
    completions = { lsp = { enabled = true } },
  },
}
