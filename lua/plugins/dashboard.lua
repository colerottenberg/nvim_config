return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = table.concat({
          "██████   █████                   █████   █████  ███                 ",
          "▒▒██████ ▒▒███                   ▒▒███   ▒▒███  ▒▒▒                  ",
          " ▒███▒███ ▒███   ██████   ██████  ▒███    ▒███  ████  █████████████  ",
          " ▒███▒▒███▒███  ███▒▒███ ███▒▒███ ▒███    ▒███ ▒▒███ ▒▒███▒▒███▒▒███ ",
          " ▒███ ▒▒██████ ▒███████ ▒███ ▒███ ▒▒███   ███   ▒███  ▒███ ▒███ ▒███ ",
          " ▒███  ▒▒█████ ▒███▒▒▒  ▒███ ▒███  ▒▒▒█████▒    ▒███  ▒███ ▒███ ▒███ ",
          " █████  ▒▒█████▒▒██████ ▒▒██████     ▒▒███      █████ █████▒███ █████",
          "▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒▒   ▒▒▒▒▒▒       ▒▒▒      ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒ ▒▒▒▒▒",
        }, "\n"),
        keys = {
          {
            key = "n",
            action = "<Cmd>enew<CR>",
            desc = "New file",
          },
          {
            key = "f",
            action = function()
              require("snacks").picker.files {
                hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
              }
            end,
            desc = "Find a file",
          },
          {
            key = "w",
            action = function() require("snacks").picker.grep() end,
            desc = "Grep a word",
          },
          {
            key = "s",
            action = function() require("resession").load() end,
            desc = "Load a session",
          },
          {
            key = "c",
            action = function()
              require("snacks").picker.files { dirs = { vim.fn.stdpath "config" }, desc = "Config Files" }
            end,
            desc = "Config",
          },
          {
            key = "g",
            action = function()
              local astro = require "astrocore"
              local worktree = astro.file_worktree()
              local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir)
                or ""
              astro.toggle_term_cmd { cmd = "lazygit " .. flags, direction = "float" }
            end,
            desc = "Open LazyGit",
          },
          {
            key = "t",
            action = function() require("snacks").picker.colorschemes() end,
            desc = "Select a colorscheme",
          },
        },
      },
    },
  },
}
