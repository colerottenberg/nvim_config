return {
  'TheLeoP/powershell.nvim',
  cond = function()
    return vim.fn.has('win32') == 1
  end,
  -- ft = 'ps1',
  ---@type powershell.user_config
  opts = {
    bundle_path = vim.fn.stdpath('data'),
  },
}
