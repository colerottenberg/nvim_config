-- Pretty in-buffer markdown rendering (also used for Avante output).

return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "Avante" },
  cmd = "RenderMarkdown",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<Leader>um", "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown rendering" },
  },
  opts = {
    file_types = { "markdown", "Avante" },
    completions = { lsp = { enabled = true } },
  },
}
