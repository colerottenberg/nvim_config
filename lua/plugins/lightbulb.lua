-- Ghost-text lightbulb for available LSP code actions (VS Code parity).
--
-- LSP has no push notification for "a code action is now available" — this
-- polls `textDocument/codeAction` on CursorHold/CursorHoldI (debounced by
-- `updatetime`) and renders a lightbulb when the result is non-empty.

return {
  "kosayoda/nvim-lightbulb",
  event = "LspAttach",
  cond = not vim.g.vscode,
  opts = {
    autocmd = { enabled = true },
    sign = { enabled = false },
    virtual_text = { enabled = true, text = "", hl = "LightBulbVirtualText" },
  },
}
