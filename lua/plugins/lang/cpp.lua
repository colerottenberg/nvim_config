-- C / C++ / CUDA: clangd config + clangd_extensions + cmake-tools.
-- Buffer-local symbol keymaps live in after/ftplugin/cpp.lua.

-- Switch between source and header (clangd LSP command).
return {
  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    keys = {
      {
        '<Leader>lw',
        function()
          require('clangd_extensions.switch_source_header').switch_source_header()
        end,
        desc = 'Switch header/source',
      },
      {
        '<Localleader>a',
        function()
          require('clangd_extensions.switch_source_header').switch_source_header()
        end,
        desc = 'Switch header/source',
      },
    },
  },

  {
    'Civitasv/cmake-tools.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
},
  vim.lsp.enable('clangd')
