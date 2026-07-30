return {
  'mason-org/mason.nvim',
  cmd = 'Mason',
  ---@type MasonSettings
  opts = {
    -- use system tools before mason tools
    max_concurrent_installers = 10,
  },
  keys = {
    {
      '<Leader>pm',
      function()
        require('mason.api.command').Mason()
      end,
      desc = 'Mason',
    },
    {
      '<Leader>pL',
      function()
        require('mason.api.command').MasonLog()
      end,
      desc = 'Mason log',
    },
    {
      '<Leader>pl',
      function()
        require('mason.api.command').MasonUpdate()
      end,
      desc = 'Mason Update',
    },
  },
}
