return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- navigate buffer tabs with `H` and `L`
          L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
          H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

          -- Old Keymap for searching current buffer with Snacks
          ["<Leader>f/"] = {
            function() require("snacks").picker.lines() end,
            desc = "Find word in buffer",
          },
          -- mappings seen under group name "Buffer"
          ["<Leader>bD"] = {
            function()
              require("astroui.status.heirline").buffer_picker(
                function(bufnr) require("astrocore.buffer").close(bufnr) end
              )
            end,
            desc = "Pick to close",
          },
          -- tables with just a `desc` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          ["<Leader>b"] = { desc = "Buffers" },

          -- quick save
          ["<C-s>"] = { ":w!<cr>", desc = "Save File" }, -- change description but the same command

          -- Adding Twilight Toggle
          ["<Leader>ux"] = {
            function() require("twilight.view").toggle() end,
            desc = "Toggle Twilight",
          },

          -- AstroCore Reload as a keybinding
          ["<Leader>pr"] = {
            function() require("astrocore").reload() end,
            desc = "AstroCore Reload (Expiremental)",
          },

          -- Picker LSP Diagnostics
          ["<Leader>lc"] = {
            function() require("snacks").picker.lsp_config() end,
            desc = "LSP Config",
          },

          -- View Lazy Plugins
          ["<Leader>pl"] = {
            function() require("snacks").picker.lazy() end,
            desc = "View Lazy Plugins",
          },

          -- Snacks Github CLI Keymaps
          ["<Leader>gh"] = { desc = "GitHub Commands" },
          ["<Leader>ghi"] = {
            function() require("snacks").picker.gh_issue() end,
            desc = "GitHub Actions Issues (open)",
          },
          ["<Leader>ghI"] = {
            function() require("snacks").picker.gh_issue { state = "all" } end,
            desc = "GitHub Actions Issues (all)",
          },
          ["<Leader>ghp"] = {
            function() require("snacks").picker.gh_pr() end,
            desc = "GitHub Actions Issues (open)",
          },
          ["<Leader>ghP"] = {
            function() require("snacks").picker.gh_pr { state = "all" } end,
            desc = "GitHub Actions Issues (all)",
          },

          -- Markview Commands
          ["<Leader>P"] = { desc = "Markview" },
          ["<Leader>Pt"] = {
            function()
              local current_buffer = vim.api.nvim_get_current_buf()
              require("markview.actions").toggle(current_buffer)
            end,
            desc = "Markview toggle",
          },
          ["<Leader>Ps"] = {
            function()
              local current_buffer = vim.api.nvim_get_current_buf()
              require("markview.actions").splitToggle()
            end,
            desc = "Markview Split",
          },
          ["<Leader>Ph"] = {
            function() require("markview.health").view() end,
            desc = "View Markview health",
          },
        },
        -- first key is the mode
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
}
