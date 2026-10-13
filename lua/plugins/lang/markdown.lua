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
    ---@type LazyKeys[]
    keys = {
      {
        '<Leader>um',
        '<Cmd>RenderMarkdown toggle<CR>',
        desc = 'Toggle markdown rendering',
      },
      {
        '<LocalLeader>t',
        function()
          require('render-markdown').buf_toggle()
        end,
        desc = 'Toggle rendering',
        ft = { 'markdown' },
      },
      {
        '<localleader>p',
        function()
          require('render-markdown').preview()
        end,
        desc = 'Preview rendering',
        ft = { 'markdown' },
      },
    },
    ---@type render.md.Config
    opts = {
      file_types = { 'markdown' },
      completions = {
        blink = { enabled = true },
        lsp = { enabled = true },
      },
    },
  },
}
