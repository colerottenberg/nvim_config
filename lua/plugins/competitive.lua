return {
  {
    'kawre/leetcode.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'folke/snacks.nvim',
    },
    ---@type lc.UserConfig
    opts = {
      lang = 'cpp',
      injector = { ---@type table<lc.lang, lc.inject>
        ['cpp'] = {
          before = { '#include <gtest/gtest.h>' },
          imports = function()
            -- return a different list to omit default imports
            local useful_stl = {
              '#include <vector>',
              '#include <algorithm>',
              '#include <functional>',
              'using namespace std;',
            }
            return useful_stl
          end,
          after = {
            'class SolutionFixture : public ::testing::Test',
            '{',
            '  protected:',
            '    Solution s;',
            '};',
            '',
            'TEST_F(SolutionFixture, Example1)',
            '{',
            '}',
            '',
            'int main(int argc, char **argv) {',
            '::testing::InitGoogleTest(&argc, argv);',
            'return RUN_ALL_TESTS();',
            '}',
          },
        },
      },
    },
    event = 'VeryLazy',
    keys = {
      { '<Leader>Lm', vim.cmd.Leet, desc = 'Leetcode Menu' },
      {
        '<Leader>Lc',
        function()
          local lc = require('leetcode.command')
          lc.change_lang()
        end,
        desc = 'change language',
      },
      {
        '<Leader>Ls',
        function()
          local lc = require('leetcode.command')
          lc.q_submit()
        end,
        desc = 'submit',
      },
      {
        '<Leader>Lr',
        function()
          local lc = require('leetcode.command')
          lc.q_run()
        end,
        desc = 'run test cases',
      },
      {
        '<Leader>Lh',
        function()
          local lc = require('leetcode.command')
          lc.hints()
        end,
        desc = 'hints',
      },
      {
        '<Leader>Lp',
        function()
          local lc = require('leetcode.command')
          lc.desc_toggle()
        end,
        desc = 'toggle description',
      },
      {
        '<Leader>Lq',
        function()
          local lc = require('leetcode.command')
          lc.exit()
        end,
        desc = 'exit',
      },
    },
  },

  {
    'xeluxee/competitest.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    event = 'VeryLazy',
    config = function()
      ---@type competitest.Config
      local opts = {}
      require('competitest').setup()
    end,
  },
}
