-- Discord Rich Presence.

return {
  'andweeb/presence.nvim',
  event = 'VeryLazy',
  cond = not vim.g.vscode,
  config = function()
    require('presence'):setup({})
  end,
}
