-- Session management (replaces AstroNvim's resession setup). Dirsessions are
-- keyed by cwd; a "last" session is autosaved on exit.

local resession = require "resession"

resession.setup {
  extensions = {},
}

local function cwd() return vim.fn.getcwd() end

local map = vim.keymap.set
map("n", "<Leader>Ss", function() resession.save() end, { desc = "Save session" })
map("n", "<Leader>St", function() resession.save_tab() end, { desc = "Save tab session" })
map(
  "n",
  "<Leader>SS",
  function() resession.save(cwd(), { dir = "dirsession", notify = true }) end,
  { desc = "Save dirsession (cwd)" }
)
map(
  "n",
  "<Leader>S.",
  function() resession.load(cwd(), { dir = "dirsession" }) end,
  { desc = "Load current dirsession" }
)
map("n", "<Leader>Sl", function() resession.load "last" end, { desc = "Load last session" })
map("n", "<Leader>Sf", function() resession.load() end, { desc = "Load session" })
map("n", "<Leader>SF", function() resession.load(nil, { dir = "dirsession" }) end, { desc = "Load dirsession" })
map("n", "<Leader>Sd", function() resession.delete() end, { desc = "Delete session" })
map("n", "<Leader>SD", function() resession.delete(nil, { dir = "dirsession" }) end, { desc = "Delete dirsession" })

-- Auto-save "last" and the cwd dirsession on exit.
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("user_resession_autosave", { clear = true }),
  callback = function()
    resession.save("last", { notify = false })
    resession.save(cwd(), { dir = "dirsession", notify = false })
  end,
})
