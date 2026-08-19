return {
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
