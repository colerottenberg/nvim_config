---@type LazySpec
return {
  'TheLeoP/powershell.nvim',
  cond = function()
    return vim.fn.has('win32') == 1
  end,
  ft = 'ps1',
  ---@type powershell.user_config
  opts = {
    bundle_path = vim.fn.stdpath('data') .. '/PowerShellEditorServices',
  },
  keys = {
    {
      '<LocalLeader>t',
      function()
        require('powershell').toggle_term()
      end,
      desc = 'PowerShell Terminal',
      mode = 'n',
      ft = 'ps1',
    },
    {
      '<LocalLeader>e',
      function()
        require('powershell').eval()
      end,
      desc = 'Evaluate PowerShell',
      mode = 'n',
      ft = 'ps1',
    },
  },
}
