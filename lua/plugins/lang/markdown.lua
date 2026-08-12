return {
  {
    'obsidian-nvim/obsidian.nvim',
    version = '*', -- use latest release, remove to use latest commit
    cond = function()
      return vim.fn.executable('obsidian') == 1
    end,
    ft = 'markdown',
    cmd = 'Obsidian',
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      picker = {
        name = 'snacks.picker',
      },
      legacy_commands = false, -- this will be removed in 4.0.0
      workspaces = {
        {
          name = 'resnav',
          path = '~/Documents/ResNav',
        },
        {
          name = 'personal',
          path = '~/Documents/Personal',
        },
      },
    },
    dependencies = {
      'folke/snacks.nvim',
    },
  },
  -- automatic bulleted lists
  ---@type LazySpec
  {
    'bullets-vim/bullets.nvim',
    ft = { 'markdown' },
    ---@type bullets.Config
    opts = {
      enabled_file_types = { 'markdown', 'text', 'gitcommit' },
    },
  },
  --- Rendering Markdown
  ---@type LazySpec
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    cmd = 'RenderMarkdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { '<Leader>um', '<Cmd>RenderMarkdown toggle<CR>', desc = 'Toggle markdown rendering' },
    },
    opts = {
      file_types = { 'markdown' },
      completions = { lsp = { enabled = true } },
    },
  },
}
