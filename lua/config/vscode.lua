-- VS Code (vscode-neovim) specific mappings. No-op in a normal terminal / GUI.
--
-- Ported from the old `lua/plugins/vscode.lua`. When running embedded in
-- VS Code / VSCodium, `vim.g.vscode` is set and the `vscode` Lua module is
-- available; these map the config's keymap surface onto VS Code commands.

if not vim.g.vscode then return end

local vscode = require "vscode"
local map = vim.keymap.set
local function action(name)
  return function() vscode.action(name) end
end

-- Suppress "N lines yanked" etc. from reaching the VS Code output channel.
vim.opt.report = 9999

-- Buffer / editor tabs (matching the H/L convention).
map("n", "H", action "workbench.action.previousEditor", { desc = "Previous editor tab" })
map("n", "L", action "workbench.action.nextEditor", { desc = "Next editor tab" })

-- Splits.
map("n", "|", action "workbench.action.splitEditor", { desc = "Split right" })
map("n", "\\", action "workbench.action.splitEditorDown", { desc = "Split down" })
map("n", "<C-H>", action "workbench.action.navigateLeft", { desc = "Move left" })
map("n", "<C-J>", action "workbench.action.navigateDown", { desc = "Move down" })
map("n", "<C-K>", action "workbench.action.navigateUp", { desc = "Move up" })
map("n", "<C-L>", action "workbench.action.navigateRight", { desc = "Move right" })

-- Diagnostics.
map("n", "]d", action "editor.action.marker.nextInFiles", { desc = "Next diagnostic" })
map("n", "[d", action "editor.action.marker.prevInFiles", { desc = "Previous diagnostic" })

-- Call hierarchy.
map("n", "gai", action "editor.showCallHierarchy", { desc = "Call hierarchy (incoming)" })
map("n", "gao", function()
  vscode.action "editor.showCallHierarchy"
  vim.defer_fn(function() vscode.action "editor.showOutgoingCalls" end, 200)
end, { desc = "Call hierarchy (outgoing)" })
map("n", "gaI", action "references-view.showCallHierarchy", { desc = "Incoming calls (tree)" })
map("n", "gaO", action "references-view.showOutgoingCalls", { desc = "Outgoing calls (tree)" })

-- Workspace / LSP.
map("n", "gw", action "workbench.action.addRootFolder", { desc = "Add workspace folder" })
map("n", "gR", action "editor.action.goToReferences", { desc = "LSP references" })
map("n", "<Leader>lW", action "workbench.action.addRootFolder", { desc = "Add workspace folder" })
map("n", "<Leader>lc", action "workbench.action.openSettings", { desc = "Open settings" })
map("n", "<Leader>ls", action "workbench.action.gotoSymbol", { desc = "Document symbols" })
map("n", "<Leader>lg", action "workbench.action.showAllSymbols", { desc = "Search workspace symbols" })
map("n", "<Leader>ld", action "workbench.actions.view.problems", { desc = "Open problems panel" })
map("n", "<Leader>fk", action "workbench.action.openGlobalKeybindings", { desc = "Keymaps (VSCodium)" })
map("n", "<Leader>ft", action "workbench.action.selectTheme", { desc = "Select theme" })

-- Git.
map("n", "]g", action "workbench.action.editor.nextChange", { desc = "Next git hunk" })
map("n", "[g", action "workbench.action.editor.previousChange", { desc = "Previous git hunk" })
map("n", "<Leader>gc", action "git.viewHistory", { desc = "Git commits (repository)" })
map("n", "<Leader>gC", action "git.viewFileHistory", { desc = "Git commits (file)" })
map("n", "<Leader>gb", action "git.branchFrom", { desc = "Git branches" })
map("n", "<Leader>gB", action "gitlens.toggleFileBlame", { desc = "Toggle git blame" })
map("n", "<Leader>gd", action "git.openChange", { desc = "Git diff (file)" })
map("n", "<Leader>gs", action "workbench.view.scm", { desc = "Git status" })
map("n", "<Leader>gS", action "git.stageAll", { desc = "Stage all changes" })
map("n", "<Leader>gu", action "git.unstageAll", { desc = "Unstage all changes" })
map("n", "<Leader>gr", action "git.revertChange", { desc = "Revert hunk" })
map("n", "<Leader>gp", action "git.pull", { desc = "Git pull" })
map("n", "<Leader>gP", action "git.push", { desc = "Git push" })

-- Explorer / UI.
map("n", "<Leader>e", action "workbench.action.toggleSidebarVisibility", { desc = "Toggle sidebar" })
map("n", "<Leader>o", action "workbench.action.focusSideBar", { desc = "Focus sidebar" })
map("n", "<Leader>uh", action "clangd.inlayHints.toggle", { desc = "Toggle inlay hints" })
map("n", "<Leader>uZ", action "workbench.action.toggleZenMode", { desc = "Toggle zen mode" })

-- Debug.
map("n", "<Leader>db", action "editor.debug.action.toggleBreakpoint", { desc = "Toggle breakpoint" })
map("n", "<Leader>dB", action "editor.debug.action.toggleInlineBreakpoint", { desc = "Toggle inline breakpoint" })
map("n", "<Leader>dc", action "workbench.action.debug.continue", { desc = "Continue" })
map("n", "<Leader>dp", action "workbench.action.debug.pause", { desc = "Pause" })
map("n", "<Leader>ds", action "workbench.action.debug.start", { desc = "Start debugging" })
map("n", "<Leader>dS", action "workbench.action.debug.stop", { desc = "Stop debugging" })
map("n", "<Leader>di", action "workbench.action.debug.stepInto", { desc = "Step into" })
map("n", "<Leader>do", action "workbench.action.debug.stepOut", { desc = "Step out" })
map("n", "<Leader>dn", action "workbench.action.debug.stepOver", { desc = "Step over" })
map("n", "<Leader>dr", action "workbench.action.debug.restart", { desc = "Restart debugging" })
map("n", "<Leader>dw", action "workbench.debug.action.toggleRepl", { desc = "Toggle debug console" })
map("n", "<Leader>du", action "workbench.debug.action.focusCallStackView", { desc = "Focus call stack" })
