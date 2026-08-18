-- C / C++ / CUDA: clangd config + clangd_extensions + cmake-tools.
-- Buffer-local symbol keymaps live in after/ftplugin/cpp.lua.

return {
  ---@type LazySpec
  {
    'Civitasv/cmake-tools.nvim',
    ft = { 'c', 'cpp', 'cmake', 'objc', 'objcpp', 'cuda', 'proto' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = {
      'CMakeGenerate',
      'CMakeBuild',
      'CMakeBuildCurrentFile',
      'CMakeRun',
      'CMakeRunCurrentFile',
      'CMakeDebug',
      'CMakeDebugCurrentFile',
      'CMakeRunTest',
      'CMakeLaunchArgs',
      'CMakeSelectBuildType',
      'CMakeSelectBuildTarget',
      'CMakeSelectLaunchTarget',
      'CMakeSelectKit',
      'CMakeSelectConfigurePreset',
      'CMakeSelectBuildPreset',
      'CMakeSelectTestPreset',
      'CMakeSelectCwd',
      'CMakeSelectBuildDir',
      'CMakeOpen',
      'CMakeOpenCache',
      'CMakeClose',
      'CMakeInstall',
      'CMakeClean',
      'CMakeStop',
      'CMakeQuickBuild',
      'CMakeQuickRun',
      'CMakeQuickDebug',
      'CMakeShowTargetFiles',
      'CMakeQuickStart',
      'CMakeSettings',
      'CMakeTargetSettings',
    },
    opts = {},
    dependencies = { 'stevearc/overseer.nvim', 'akinsho/toggleterm.nvim' },
  },
  ---@type LazySpec
  {
    'dchinmay2/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },

    cmd = { 'ClangdSwitchSourceHeader', 'ClangdAST' },
    config = function(_, opts)
      local clangd_extensions = require('clangd_extensions')
      clangd_extensions.setup({
        ast = {
          role_icons = {
            type = '',
            declaration = '',
            expression = '',
            specifier = '',
            statement = '',
            ['template argument'] = '',
          },

          kind_icons = {
            Compound = '',
            Recovery = '',
            TranslationUnit = '',
            PackExpansion = '',
            TemplateTypeParm = '',
            TemplateTemplateParm = '',
            TemplateParamObject = '',
          },

          highlights = {
            detail = 'Comment',
          },
        },
        memory_usage = {
          border = 'none',
        },
        symbol_info = {
          border = 'none',
        },
      })
    end,
    keys = {
      {
        '<Leader>lw',
        '<Cmd>ClangdSwitchSourceHeader<CR>',
        ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        desc = 'Switch Source/Header',
      },
    },
  },
}
