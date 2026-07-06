-- Autocommands.
--
-- Reproduces the useful groups AstroNvim provided by default
-- (`_astrocore_autocmds.lua`). Session auto-save lives in `plugins/resession.lua`
-- and colorscheme caching in `plugins/colorschemes.lua`.

local function augroup(name) return vim.api.nvim_create_augroup("user_" .. name, { clear = true }) end
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text.
autocmd("TextYankPost", {
  group = augroup "highlight_yank",
  desc = "Highlight yanked text",
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})

-- Restore the last cursor position when reopening a file.
autocmd("BufReadPost", {
  group = augroup "restore_cursor",
  desc = "Restore last cursor position",
  callback = function(args)
    if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo[args.buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Create missing parent directories on save.
autocmd("BufWritePre", {
  group = augroup "create_dir",
  desc = "Auto create parent directories when saving a file",
  callback = function(args)
    if args.match:match "^%w%w+://" then return end -- ignore non-file (e.g. oil://) buffers
    local file = vim.uv.fs_realpath(args.match) or args.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Reload files changed outside of Neovim when regaining focus.
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup "checktime",
  desc = "Check for external file changes",
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd "checktime" end
  end,
})

-- `q` closes transient/utility windows, and unlist the quickfix buffer.
autocmd("FileType", {
  group = augroup "close_with_q",
  desc = "Close utility windows with q",
  pattern = {
    "help",
    "man",
    "qf",
    "lspinfo",
    "checkhealth",
    "notify",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "neotest-summary",
    "dap-float",
    "query",
  },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set(
      "n",
      "q",
      "<Cmd>close<CR>",
      { buffer = args.buf, silent = true, nowait = true, desc = "Close window" }
    )
  end,
})
