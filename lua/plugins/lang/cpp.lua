-- C / C++ / CUDA: clangd config + clangd_extensions + cmake-tools.
-- All cpp/cmake keymaps live in this file's `keys` table below.

local cmake_ft = { 'c', 'cpp', 'cmake', 'objc', 'objcpp', 'cuda', 'proto' }

return {
  ---@type LazySpec
  {
    'Civitasv/cmake-tools.nvim',
    ft = { 'c', 'cpp', 'cmake', 'objc', 'objcpp', 'cuda', 'proto' },
    dependencies = { 'stevearc/overseer.nvim', 'akinsho/toggleterm.nvim', 'nvim-lua/plenary.nvim' },
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
    config = function()
      local osys = require('cmake-tools.osys')
      require('cmake-tools').setup({
        cmake_command = 'cmake',                                          -- this is used to specify cmake command path
        ctest_command = 'ctest',                                          -- this is used to specify ctest command path
        ctest_show_labels = false,                                        -- also show labels in the test picker
        cmake_use_preset = true,
        cmake_regenerate_on_save = true,                                  -- auto generate when save CMakeLists.txt
        cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' }, -- this will be passed when invoke `CMakeGenerate`
        cmake_build_options = {},                                         -- this will be passed when invoke `CMakeBuild`
        -- support macro expansion:
        --       ${kit}
        --       ${kitGenerator}
        --       ${variant:xx}
        cmake_build_directory = function()
          if osys.iswin32 then
            return 'out\\${variant:buildType}'
          end
          return 'out/${variant:buildType}'
        end,                    -- this is used to specify generate directory for cmake, allows macro expansion, can be a string or a function returning the string, relative to cwd.
        cmake_compile_commands_options = {
          action = 'soft_link', -- available options: soft_link, copy, lsp, none
          -- soft_link: this will automatically make a soft link from compile commands file to target
          -- copy:      this will automatically copy compile commands file to target
          -- lsp:       this will automatically set compile commands file location using lsp
          -- none:      this will make this option ignored
          target = vim.loop.cwd,                   -- path or function returning path to directory, this is used only if action == "soft_link" or action == "copy"
        },
        cmake_kits_path = nil,                     -- this is used to specify global cmake kits path, see CMakeKits for detailed usage
        cmake_variants_message = {
          short = { show = true },                 -- whether to show short message
          long = { show = true, max_length = 40 }, -- whether to show long message
        },
        cmake_dap_configuration = {                -- debug settings for cmake
          name = 'cpp',
          type = 'codelldb',
          request = 'launch',
          stopOnEntry = false,
          runInTerminal = true,
          console = 'integratedTerminal',
        },
        cmake_executor = {   -- executor to use
          name = 'overseer', -- name of the executor
          opts = {},         -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
          default_opts = {   -- a list of default and possible values for executors
            overseer = {
              -- strategy left unset: falls back to overseer's default 'jobstart' strategy.
              -- overseer.nvim removed its 'toggleterm' strategy (see stevearc/overseer.nvim@5764e36),
              -- so cmake-tools' README example config no longer works as documented.
              new_task_opts = {},
              on_new_task = function(task)
                require('overseer').open({ enter = false, direction = 'bottom' })
              end, -- a function that gets overseer.Task when it is created, before calling `task:start`
            },
          },
        },
        cmake_runner = {     -- runner to use
          name = 'overseer', -- name of the runner
          opts = {},         -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
          default_opts = {   -- a list of default and possible values for runners
            overseer = {
              new_task_opts = {},
              on_new_task = function(task)
                require('overseer').open({ enter = false, direction = 'bottom' })
              end, -- a function that gets overseer.Task when it is created, before calling `task:start`
            },
          },
        },
        cmake_notifications = {
          runner = { enabled = true },
          executor = { enabled = true },
          spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }, -- icons used for progress display
          refresh_rate_ms = 100, -- how often to iterate icons
        },
        cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at bottom corner)
        cmake_use_scratch_buffer = false, -- A buffer that shows what cmake-tools has done
      })
    end,
    keys = {
      -- Core workflow
      {
        '<LocalLeader>g',
        function()
          vim.cmd.CMakeGenerate()
        end,
        desc = 'CMake Generate',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>b',
        function()
          vim.cmd.CMakeBuild()
        end,
        desc = 'CMake Build',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>B',
        function()
          vim.cmd.CMakeBuildCurrentFile()
        end,
        desc = 'CMake Build Current File',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>r',
        function()
          vim.cmd.CMakeRun()
        end,
        desc = 'CMake Run',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>R',
        function()
          vim.cmd.CMakeRunCurrentFile()
        end,
        desc = 'CMake Run Current File',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>d',
        function()
          vim.cmd.CMakeDebug()
        end,
        desc = 'CMake Debug',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>D',
        function()
          vim.cmd.CMakeDebugCurrentFile()
        end,
        desc = 'CMake Debug Current File',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>t',
        function()
          vim.cmd.CMakeRunTest()
        end,
        desc = 'CMake Run Test',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>i',
        function()
          vim.cmd.CMakeInstall()
        end,
        desc = 'CMake Install',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>c',
        function()
          vim.cmd.CMakeClean()
        end,
        desc = 'CMake Clean',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>x',
        function()
          vim.cmd.CMakeStop()
        end,
        desc = 'CMake Stop',
        ft = cmake_ft,
      },

      -- Quick workflow (generate + build/run/debug in one step)
      {
        '<LocalLeader>qb',
        function()
          vim.cmd.CMakeQuickBuild()
        end,
        desc = 'CMake Quick Build',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>qr',
        function()
          vim.cmd.CMakeQuickRun()
        end,
        desc = 'CMake Quick Run',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>qd',
        function()
          vim.cmd.CMakeQuickDebug()
        end,
        desc = 'CMake Quick Debug',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>qs',
        function()
          vim.cmd.CMakeQuickStart()
        end,
        desc = 'CMake Quick Start',
        ft = cmake_ft,
      },

      -- Selection (kit/target/preset/cwd)
      {
        '<LocalLeader>sk',
        function()
          vim.cmd.CMakeSelectKit()
        end,
        desc = 'CMake Select Kit',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>sb',
        function()
          vim.cmd.CMakeSelectBuildType()
        end,
        desc = 'CMake Select Build Type',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>st',
        function()
          vim.cmd.CMakeSelectBuildTarget()
        end,
        desc = 'CMake Select Build Target',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>sl',
        function()
          vim.cmd.CMakeSelectLaunchTarget()
        end,
        desc = 'CMake Select Launch Target',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>sw',
        function()
          vim.cmd.CMakeSelectCwd()
        end,
        desc = 'CMake Select Cwd',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>sd',
        function()
          vim.cmd.CMakeSelectBuildDir()
        end,
        desc = 'CMake Select Build Dir',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>spc',
        function()
          vim.cmd.CMakeSelectConfigurePreset()
        end,
        desc = 'CMake Select Configure Preset',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>spb',
        function()
          vim.cmd.CMakeSelectBuildPreset()
        end,
        desc = 'CMake Select Build Preset',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>spt',
        function()
          vim.cmd.CMakeSelectTestPreset()
        end,
        desc = 'CMake Select Test Preset',
        ft = cmake_ft,
      },

      -- Open / settings / misc
      {
        '<LocalLeader>oo',
        function()
          vim.cmd.CMakeOpen()
        end,
        desc = 'CMake Open',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>oc',
        function()
          vim.cmd.CMakeOpenCache()
        end,
        desc = 'CMake Open Cache',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>ox',
        function()
          vim.cmd.CMakeClose()
        end,
        desc = 'CMake Close',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>os',
        function()
          vim.cmd.CMakeSettings()
        end,
        desc = 'CMake Settings',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>ot',
        function()
          vim.cmd.CMakeTargetSettings()
        end,
        desc = 'CMake Target Settings',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>of',
        function()
          vim.cmd.CMakeShowTargetFiles()
        end,
        desc = 'CMake Show Target Files',
        ft = cmake_ft,
      },
      {
        '<LocalLeader>oa',
        function()
          vim.cmd.CMakeLaunchArgs()
        end,
        desc = 'CMake Launch Args',
        ft = cmake_ft,
      },
    },
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
