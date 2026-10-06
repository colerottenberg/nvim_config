-- which-key: keymap hints + <Leader> group names.

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    icons = { group = '', rules = false, separator = '-' },
    spec = {
      { '<Leader>b', group = 'Buffers' },
      { '<Leader>bs', group = 'Sort Buffers' },
      { '<Leader>d', group = 'Debugger' },
      { '<Leader>f', group = 'Find' },
      { '<Leader>g', group = 'Git' },
      { '<Leader>l', group = 'Language Tools' },
      { '<Leader>L', group = 'Leetcode' },
      { '<Leader>ly', group = 'Type Hierarchy' },
      { '<Leader>m', group = 'Overseer' },
      { '<Leader>o', group = 'Opencode' },
      { '<Leader>p', group = 'Packages' },
      { '<Leader>s', group = 'Session' },
      { '<Leader>t', group = 'Terminal' },
      { '<Leader>T', group = 'Tests' },
      { '<Leader>u', group = 'UI/UX' },
      { '<Leader>x', group = 'Quickfix/Lists' },
      { 'ga', group = 'Hierarchy' },
      { 'gr', group = 'LSP' },
    },
  },
}
