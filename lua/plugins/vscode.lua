-- VSCode-specific keymaps and overrides
-- These extend the astrocommunity.recipes.vscode recipe with custom bindings
-- that match the current AstroNvim keymap surface.

if not vim.g.vscode then return {} end

local vscode = require "vscode"

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

          -- Call hierarchy (ga group)
          ["ga"] = { desc = "View Calls" },
          ["gai"] = {
            function() vscode.action "references-view.showCallHierarchy" end,
            desc = "Incoming Calls",
          },
          ["gao"] = {
            function() vscode.action "editor.showOutgoingCalls" end,
            desc = "Outgoing Calls",
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
          ["<Leader>lg"] = {
            function() vscode.action "workbench.action.showAllSymbols" end,
            desc = "Search Workspace Symbols",
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
