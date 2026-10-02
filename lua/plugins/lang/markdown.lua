return {
  -- automatic bulleted lists
  ---@type LazySpec
  {
    'bullets-vim/bullets.nvim',
    ft = { 'markdown', 'opencode', 'text', 'gitcommit' },
    ---@type bullets.Config
    opts = {
      enabled_file_types = { 'markdown', 'text', 'gitcommit', 'opencode' },
    },
  },
  --- Rendering Markdown
  ---@type LazySpec
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'Avante' },
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
