-- VS Code (vscode-neovim) specific mappings. No-op in a normal terminal / GUI.
--
-- Ported from the old `lua/plugins/vscode.lua`. When running embedded in
-- VS Code / VSCodium, `vim.g.vscode` is set and the `vscode` Lua module is
-- available; these map the config's keymap surface onto VS Code commands.
--
-- Command-ID completion comes from the `vscode.Action` alias in
-- `vscode-actions.lua` (a ---@meta file generated from keybindings.json).
-- Any string typed inside `action(...)` or `act(...)` gets literal
-- completion from that alias.

if not vim.g.vscode then return end

local vscode = require "vscode"

-- set clipboard
vim.g.clipboard = vim.g.vscode_clipboard

-- remapping
local map = vim.keymap.set

--- Fire a VS Code command immediately.
---@param name vscode.Action
---@param opts? table Options forwarded to vscode.action (args, range, callback, ...)
local function act(name, opts) vscode.action(name, opts) end

--- Return a closure that fires a VS Code command (for use as a keymap RHS).
---@param name vscode.Action
---@return function
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

-- Core LSP navigation (matches the native vim.lsp `gr*` defaults + our `<Leader>l*`).
map("n", "gd", action "editor.action.revealDefinition", { desc = "Go to definition" })
map("n", "gD", action "editor.action.revealDeclaration", { desc = "Go to declaration" })
map("n", "gI", action "editor.action.goToImplementation", { desc = "Go to implementation" })
map("n", "gri", action "editor.action.goToImplementation", { desc = "Go to implementation" })
map("n", "grr", action "editor.action.goToReferences", { desc = "Go to references" })
map("n", "gra", action "editor.action.quickFix", { desc = "Code action" })
map("n", "grn", action "editor.action.rename", { desc = "Rename symbol" })
map("n", "grx", action "codelens.showLensesInCurrentLine", { desc = "Rename symbol" })
map("n", "gO", action "workbench.action.gotoSymbol", { desc = "Document symbols" })
map("n", "gK", action "editor.action.triggerParameterHints", { desc = "Signature help" })
map("n", "K", action "editor.action.showHover", { desc = "Hover" })
map("n", "<Leader>la", action "editor.action.quickFix", { desc = "Code action" })
map("n", "<Leader>lr", action "editor.action.rename", { desc = "Rename symbol" })
map("n", "<Leader>lh", action "editor.action.triggerParameterHints", { desc = "Signature help" })

-- Call hierarchy.
map("n", "gai", action "editor.showIncomingCalls", { desc = "Call hierarchy (incoming)" })
map("n", "gao", function()
  act "editor.showCallHierarchy"
  vim.defer_fn(function() act "editor.showOutgoingCalls" end, 200)
end, { desc = "Call hierarchy (outgoing)" })
map("n", "gaI", action "references-view.showCallHierarchy", { desc = "Incoming calls (tree)" })
map("n", "gaO", action "references-view.showOutgoingCalls", { desc = "Outgoing calls (tree)" })
map("n", "gy", action "editor.action.goToTypeDefinition", { desc = "Go to type definition" })

-- Workspace / LSP.
map("n", "gw", action "workbench.action.addRootFolder", { desc = "Add workspace folder" })
map("n", "gR", action "editor.action.goToReferences", { desc = "LSP references" })
map("n", "<Leader>lW", action "workbench.action.addRootFolder", { desc = "Add workspace folder" })
map("n", "<Leader>lc", action "workbench.action.openSettings", { desc = "Open settings" })
map("n", "<Leader>ls", action "workbench.action.gotoSymbol", { desc = "Document symbols" })
map("n", "<Leader>lg", action "workbench.action.showAllSymbols", { desc = "Search workspace symbols" })
map("n", "<Leader>ld", action "workbench.actions.view.problems", { desc = "Open problems panel" })

-- Find files / grep (closest VS Code equivalents of the snacks.picker `<Leader>f*` set).
map("n", "<Leader>ff", action "workbench.action.quickOpen", { desc = "Find files" })
map("n", "<Leader>fb", action "workbench.action.showAllEditors", { desc = "Find buffers" })
map("n", "<Leader>fo", action "workbench.action.openRecent", { desc = "Find recent files" })
map("n", "<Leader>fw", action "workbench.action.findInFiles", { desc = "Find words (grep)" })
map("n", "<Leader>fc", action "workbench.action.findInFiles", { desc = "Find word under cursor" })
map("n", "<Leader>fl", action "actions.find", { desc = "Find in current file" })
map("n", "<Leader>fC", action "workbench.action.showCommands", { desc = "Command palette" })
map("n", "<Leader>fn", action "notifications.showList", { desc = "Find notifications" })
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
map("n", "<Leader>gr", action "git.revertSelectedRanges", { desc = "Reset hunk" })
map("n", "<Leader>gR", action "git.clean", { desc = "Reset file" })

-- Explorer / UI.
map("n", "<Leader>e", action "workbench.action.toggleSidebarVisibility", { desc = "Toggle File Explorer" })
map("n", "<Leader>o", action "workbench.files.action.showActiveFileInExplorer", { desc = "Focus sidebar" })
map("n", "<Leader>c", action "workbench.action.closeActiveEditor", { desc = "Close buffer" })
map("n", "<Leader>q", action "workbench.action.closeWindow", { desc = "Close editor" })
map("n", "<Leader>w", action "workbench.action.files.save", { desc = "Save file" })
map("n", "<Leader>uh", action "clangd.inlayHints.toggle", { desc = "Toggle inlay hints" })
map("n", "<Leader>uz", action "workbench.action.toggleZenMode", { desc = "Toggle zen mode" })
map("n", "<Leader>t", action "workbench.action.terminal.focus", { desc = "Toggle terminal" })

-- Buffer
map("n", "<Leader>bc", action "workbench.action.closeOtherEditors", { desc = "Close other buffers except current" })

-- Debug.
map("n", "<Leader>db", action "editor.debug.action.toggleBreakpoint", { desc = "Toggle breakpoint" })
map("n", "<Leader>dB", action "editor.debug.action.toggleInlineBreakpoint", { desc = "Toggle inline breakpoint" })
map("n", "<Leader>dc", action "workbench.action.debug.continue", { desc = "Continue" })
map("n", "<Leader>dp", action "workbench.action.debug.pause", { desc = "Pause" })
map("n", "<Leader>ds", action "editor.debug.action.runToCursor", { desc = "Run to cursor" })
map("n", "<Leader>dS", action "workbench.action.debug.stop", { desc = "Stop debugging" })
map("n", "<Leader>di", action "workbench.action.debug.stepInto", { desc = "Step into" })
map("n", "<Leader>dO", action "workbench.action.debug.stepOut", { desc = "Step out" })
map("n", "<Leader>do", action "workbench.action.debug.stepOver", { desc = "Step over" })
map("n", "<Leader>dr", action "workbench.action.debug.restart", { desc = "Restart debugging" })
map("n", "<Leader>dw", action "workbench.debug.action.toggleRepl", { desc = "Toggle debug console" })
map("n", "<Leader>du", action "workbench.debug.action.focusCallStackView", { desc = "Focus call stack" })
map("n", "<Leader>dC", action "workbench.action.debug.selectandstart", { desc = "Run debug configuration" })
