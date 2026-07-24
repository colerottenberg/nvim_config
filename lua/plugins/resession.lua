-- Session management. Dirsessions are keyed by cwd; a "last" session is
-- autosaved on exit (the require in the callback lazy-loads the plugin).

local function cwd()
  return vim.fn.getcwd()
end

return {
  'stevearc/resession.nvim',
  lazy = true,
  keys = {
    {
      '<Leader>ss',
      function()
        require('resession').save()
      end,
      desc = 'Save session',
    },
    {
      '<Leader>st',
      function()
        require('resession').save_tab()
      end,
      desc = 'Save tab session',
    },
    {
      '<Leader>sS',
      function()
        require('resession').save(cwd(), { dir = 'dirsession', notify = true })
      end,
      desc = 'Save dirsession (cwd)',
    },
    {
      '<Leader>s.',
      function()
        require('resession').load(cwd(), { dir = 'dirsession' })
      end,
      desc = 'Load current dirsession',
    },
    {
      '<Leader>sl',
      function()
        require('resession').load('last')
      end,
      desc = 'Load last session',
    },
    {
      '<Leader>sf',
      function()
        require('resession').load()
      end,
      desc = 'Load session',
    },
    {
      '<Leader>sF',
      function()
        require('resession').load(nil, { dir = 'dirsession' })
      end,
      desc = 'Load dirsession',
    },
    {
      '<Leader>sd',
      function()
        require('resession').delete()
      end,
      desc = 'Delete session',
    },
    {
      '<Leader>sD',
      function()
        require('resession').delete(nil, { dir = 'dirsession' })
      end,
      desc = 'Delete dirsession',
    },
  },
  init = function()
    -- Auto-save "last" and the cwd dirsession on exit.
    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = vim.api.nvim_create_augroup('user_resession_autosave', { clear = true }),
      callback = function()
        local resession = require('resession')
        resession.save('last', { notify = false })
        resession.save(cwd(), { dir = 'dirsession', notify = false })
      end,
    })
  end,
  opts = {
    extensions = {},
  },
}
