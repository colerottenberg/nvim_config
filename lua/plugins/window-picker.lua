-- Interactive window picking (used by neo-tree and others).

return {
  's1n7ax/nvim-window-picker',
  lazy = true,
  main = 'window-picker',
  opts = {
    picker_config = {
      statusline_winbar_picker = { use_winbar = 'smart' },
    },
  },
}
