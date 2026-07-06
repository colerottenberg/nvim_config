-- Inline highlighting of color codes (#rrggbb, rgb(), etc.).

require("nvim-highlight-colors").setup {
  enable_named_colors = false,
  virtual_symbol = "󱓻",
  exclude_buffer = function(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return true end
    local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(bufnr))
    return ok and stats and stats.size > 1024 * 256
  end,
}

vim.keymap.set("n", "<Leader>uz", "<Cmd>HighlightColors Toggle<CR>", { desc = "Toggle color highlight" })
