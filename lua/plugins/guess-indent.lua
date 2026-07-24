-- Detect and apply buffer indentation automatically on open.

return {
  'NMAC427/guess-indent.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = 'GuessIndent',
  opts = {},
}
