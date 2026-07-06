-- Pretty in-buffer markdown rendering (also used for Avante output).

require("render-markdown").setup {
  file_types = { "markdown", "Avante" },
  completions = { lsp = { enabled = true } },
}

vim.keymap.set("n", "<Leader>um", "<Cmd>RenderMarkdown toggle<CR>", { desc = "Toggle markdown rendering" })
