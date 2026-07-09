-- Session management. Dirsessions are keyed by cwd; a "last" session is
-- autosaved on exit (the require in the callback lazy-loads the plugin).

local function cwd() return vim.fn.getcwd() end

return {
  "stevearc/resession.nvim",
  lazy = true,
  keys = {
    { "<Leader>Ss", function() require("resession").save() end, desc = "Save session" },
    { "<Leader>St", function() require("resession").save_tab() end, desc = "Save tab session" },
    {
      "<Leader>SS",
      function() require("resession").save(cwd(), { dir = "dirsession", notify = true }) end,
      desc = "Save dirsession (cwd)",
    },
    {
      "<Leader>S.",
      function() require("resession").load(cwd(), { dir = "dirsession" }) end,
      desc = "Load current dirsession",
    },
    { "<Leader>Sl", function() require("resession").load "last" end, desc = "Load last session" },
    { "<Leader>Sf", function() require("resession").load() end, desc = "Load session" },
    { "<Leader>SF", function() require("resession").load(nil, { dir = "dirsession" }) end, desc = "Load dirsession" },
    { "<Leader>Sd", function() require("resession").delete() end, desc = "Delete session" },
    {
      "<Leader>SD",
      function() require("resession").delete(nil, { dir = "dirsession" }) end,
      desc = "Delete dirsession",
    },
  },
  init = function()
    -- Auto-save "last" and the cwd dirsession on exit.
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = vim.api.nvim_create_augroup("user_resession_autosave", { clear = true }),
      callback = function()
        local resession = require "resession"
        resession.save("last", { notify = false })
        resession.save(cwd(), { dir = "dirsession", notify = false })
      end,
    })
  end,
  opts = {
    extensions = {},
  },
}
