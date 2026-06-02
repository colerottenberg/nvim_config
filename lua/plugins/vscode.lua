-- VSCode-specific keymaps and overrides
-- These extend the astrocommunity.recipes.vscode recipe with custom bindings
-- that match the current AstroNvim keymap surface.

if not vim.g.vscode then return {} end

local vscode = require "vscode"

-- Suppress "N lines yanked" etc. from reaching VSCodium output
vim.opt.report = 9999

local enabled = {}
vim.tbl_map(function(plugin) enabled[plugin] = true end, {
  -- core plugins
  "lazy.nvim",
  "AstroNvim",
  "astrocore",
  "astroui",
  "nvim-autopairs",
  "nvim-treesitter",
  "nvim-ts-autotag",
  "nvim-treesitter-textobjects",
  -- more known working
  "dial.nvim",
  "flash.nvim",
  "flit.nvim",
  "leap.nvim",
  "mini.ai",
  "mini.comment",
  "mini.move",
  "mini.pairs",
  "mini.surround",
  "nvim-surround",
  "ts-comments.nvim",
  "vim-easy-align",
  "vim-repeat",
  "vim-sandwich",
  "yanky.nvim",
  -- feel free to open PRs to add more support!
})

local Config = require "lazy.core.config"
-- disable plugin update checking
Config.options.checker.enabled = false
Config.options.change_detection.enabled = false
-- replace the default `cond`
Config.options.defaults.cond = function(plugin) return enabled[plugin.name] end

---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          -- Buffer/tab navigation (matching bufferline H/L convention)
          ["H"] = {
            function() vscode.action "workbench.action.previousEditor" end,
            desc = "Previous editor tab",
          },
          ["L"] = {
            function() vscode.action "workbench.action.nextEditor" end,
            desc = "Next editor tab",
          },

          -- splits navigation
          ["|"] = {
            function() require("vscode").action "workbench.action.splitEditor" end,
            desc = "Split right",
          },

          ["\\"] = {
            function() require("vscode").action "workbench.action.splitEditorDown" end,
            desc = "Split down",
          },

          ["<C-H>"] = {
            function() require("vscode").action "workbench.action.navigateLeft" end,
            desc = "Move left",
          },

          ["<C-J>"] = {
            function() require("vscode").action "workbench.action.navigateDown" end,
            desc = "Move down",
          },

          ["<C-K>"] = {
            function() require("vscode").action "workbench.action.navigateUp" end,
            desc = "Move up",
          },

          ["<C-L>"] = {
            function() require("vscode").action "workbench.action.navigateRight" end,
            desc = "Move right",
          },

          -- diagnostics
          ["]d"] = {
            function() require("vscode").action "editor.action.marker.nextInFiles" end,
            desc = "Move to next diagnostic",
          },

          ["[d"] = {
            function() require("vscode").action "editor.action.marker.prevInFiles" end,
            desc = "Move to prev diagnostic",
          },

          -- Call hierarchy (ga group)
          ["ga"] = { desc = "View Calls" },
          -- Opens call hierarchy peek (incoming by default);
          -- use gat to toggle direction once open
          ["gai"] = {
            function() vscode.action "editor.showCallHierarchy" end,
            desc = "Call Hierarchy (incoming)",
          },
          ["gao"] = {
            function()
              -- Open hierarchy first (incoming), then immediately switch to outgoing
              vscode.action "editor.showCallHierarchy"
              vim.defer_fn(function() vscode.action "editor.showOutgoingCalls" end, 200)
            end,
            desc = "Call Hierarchy (outgoing)",
          },

          -- Call hierarchy in sidebar tree
          ["gaI"] = {
            function() vscode.action "references-view.showCallHierarchy" end,
            desc = "Incoming Calls (tree)",
          },
          ["gaO"] = {
            function() vscode.action "references-view.showOutgoingCalls" end,
            desc = "Outgoing Calls (tree)",
          },

          -- Workspace folder management
          ["gw"] = {
            function() vscode.action "workbench.action.addRootFolder" end,
            desc = "Add Workspace Folder",
          },

          -- LSP references (user's gR binding)
          ["gR"] = {
            function() vscode.action "editor.action.goToReferences" end,
            desc = "LSP References",
          },

          -- Leader + LSP group
          ["<Leader>lW"] = {
            function() vscode.action "workbench.action.addRootFolder" end,
            desc = "Add Workspace Folder",
          },
          ["<Leader>lc"] = {
            function() vscode.action "workbench.action.openSettings" end,
            desc = "Open Settings (LSP Config)",
          },
          ["<Leader>ls"] = {
            function() vscode.action "workbench.action.gotoSymbol" end,
            desc = "Document Symbols",
          },
          -- Keymaps viewer (VSCodium keyboard shortcuts)
          ["<Leader>fk"] = {
            function() vscode.action "workbench.action.openGlobalKeybindings" end,
            desc = "Keymaps (VSCodium)",
          },

          -- Find Colorschemes
          ["<Leader>ft"] = {
            function() vscode.action "workbench.action.selectTheme" end,
            desc = "Select theme",
          },

          ["<Leader>lg"] = {
            function() vscode.action "workbench.action.showAllSymbols" end,
            desc = "Search Workspace Symbols",
          },

          -- Git hunk navigation
          ["]g"] = {
            function() vscode.action "workbench.action.editor.nextChange" end,
            desc = "Next git hunk",
          },
          ["[g"] = {
            function() vscode.action "workbench.action.editor.previousChange" end,
            desc = "Previous git hunk",
          },

          -- Git operations
          ["<Leader>gc"] = {
            function() vscode.action "git.viewHistory" end,
            desc = "Git commits (repository)",
          },
          ["<Leader>gC"] = {
            function() vscode.action "git.viewFileHistory" end,
            desc = "Git commits (file)",
          },
          ["<Leader>gb"] = {
            function() vscode.action "git.branchFrom" end,
            desc = "Git branches",
          },
          ["<Leader>gB"] = {
            function() vscode.action "gitlens.toggleFileBlame" end,
            desc = "Toggle git blame",
          },
          ["<Leader>gd"] = {
            function() vscode.action "git.openChange" end,
            desc = "Git diff (file)",
          },
          ["<Leader>gs"] = {
            function() vscode.action "workbench.view.scm" end,
            desc = "Git status",
          },
          ["<Leader>gS"] = {
            function() vscode.action "git.stageAll" end,
            desc = "Stage all changes",
          },
          ["<Leader>gu"] = {
            function() vscode.action "git.unstageAll" end,
            desc = "Unstage all changes",
          },
          ["<Leader>gr"] = {
            function() vscode.action "git.revertChange" end,
            desc = "Revert hunk",
          },
          ["<Leader>gp"] = {
            function() vscode.action "git.pull" end,
            desc = "Git pull",
          },
          ["<Leader>gP"] = {
            function() vscode.action "git.push" end,
            desc = "Git push",
          },

          -- Explorer / sidebar toggle (replaces neo-tree <Leader>e)
          ["<Leader>e"] = {
            function() vscode.action "workbench.action.toggleSidebarVisibility" end,
            desc = "Toggle Sidebar",
          },
          ["<Leader>o"] = {
            function() vscode.action "workbench.action.focusSideBar" end,
            desc = "Focus Sidebar",
          },

          -- Toggle inlay hints
          ["<Leader>uh"] = {
            function() vscode.action "clangd.inlayHints.toggle" end,
            desc = "Toggle Inlay Hints",
          },

          -- Zen mode
          ["<Leader>uZ"] = {
            function() vscode.action "workbench.action.toggleZenMode" end,
            desc = "Toggle Zen Mode",
          },

          -- Diagnostics navigation (extends recipe's ]d/[d)
          ["<Leader>ld"] = {
            function() vscode.action "workbench.actions.view.problems" end,
            desc = "Open Problems Panel",
          },

          -- Debug keymaps (leader + d group)
          ["<Leader>d"] = { desc = "Debugger" },
          ["<Leader>db"] = {
            function() vscode.action "editor.debug.action.toggleBreakpoint" end,
            desc = "Toggle Breakpoint",
          },
          ["<Leader>dB"] = {
            function() vscode.action "editor.debug.action.toggleInlineBreakpoint" end,
            desc = "Toggle Inline Breakpoint",
          },
          ["<Leader>dc"] = {
            function() vscode.action "workbench.action.debug.continue" end,
            desc = "Continue",
          },
          ["<Leader>dp"] = {
            function() vscode.action "workbench.action.debug.pause" end,
            desc = "Pause",
          },
          ["<Leader>ds"] = {
            function() vscode.action "workbench.action.debug.start" end,
            desc = "Start Debugging",
          },
          ["<Leader>dS"] = {
            function() vscode.action "workbench.action.debug.stop" end,
            desc = "Stop Debugging",
          },
          ["<Leader>di"] = {
            function() vscode.action "workbench.action.debug.stepInto" end,
            desc = "Step Into",
          },
          ["<Leader>do"] = {
            function() vscode.action "workbench.action.debug.stepOut" end,
            desc = "Step Out",
          },
          ["<Leader>dn"] = {
            function() vscode.action "workbench.action.debug.stepOver" end,
            desc = "Step Over",
          },
          ["<Leader>dr"] = {
            function() vscode.action "workbench.action.debug.restart" end,
            desc = "Restart Debugging",
          },
          ["<Leader>dw"] = {
            function() vscode.action "workbench.debug.action.toggleRepl" end,
            desc = "Toggle Debug Console",
          },
          ["<Leader>du"] = {
            function() vscode.action "workbench.debug.action.focusCallStackView" end,
            desc = "Focus Call Stack",
          },
        },
      },
    },
  },

  -- Disable plugins that are fully replaced by VSCode
  { "akinsho/bufferline.nvim", enabled = false },
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
  { "xiyaowong/transparent.nvim", enabled = false },
  { "andweeb/presence.nvim", enabled = false },
  { "FabijanZulj/blame.nvim", enabled = false },
  { "ray-x/lsp_signature.nvim", enabled = false },
}
