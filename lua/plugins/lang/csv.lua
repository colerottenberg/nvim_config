-- CSV / TSV rendering. Buffer-local view keymaps live in after/ftplugin/csv.lua.
---@type LazySpec
return {
  'hat0uma/csvview.nvim',
  ft = { 'csv', 'tsv' },
  cmd = { 'CsvViewEnable', 'CsvViewDisable', 'CsvViewToggle' },
  opts = {
    view = {
      display_mode = 'border',
      sticky_header = {
        enabled = true,
        separator = '-',
      },
    },
    parser = {
      delimiter = {
        ft = {
          csv = ',',
          tsv = '\t',
        },
        fallbacks = {
          ',',
          '\t',
          ';',
        },
      },
      comments = {
        '#',
        '--',
        '//',
      },
    },
    keymaps = {
      jump_next_field_start = {
        '<Tab>',
        mode = { 'n', 'v' },
      },
      jump_prev_field_start = {
        '<S-Tab>',
        mode = { 'n', 'v' },
      },
      jump_next_row = {
        'j',
        mode = { 'n', 'v' },
      },
      jump_prev_row = {
        'k',
        mode = { 'n', 'v' },
      },

      textobject_field_inner = {
        'ic',
        mode = { 'o', 'x' },
        desc = 'cell',
      },
      textobject_field_outer = {
        'ac',
        mode = { 'o', 'x' },
        desc = 'cell',
      },
    },
  },
  ---@param self LazyPlugin
  ---@param opts CsvView.Options
  config = function(self, opts)
    local csvview = require('csvview')
    csvview.setup(opts)
    -- Add Toggle Mapping
    local snacks = require('snacks')
    local view_toggle = snacks.toggle.new({
      name = 'CSV View',
      get = function()
        return csvview.is_enabled(0)
      end,
      set = function(state)
        csvview.toggle(nil, opts)
      end,
      notify = true,
      which_key = true,
      map = function(mode, lhs, rhs, opts)
        snacks.keymap.set(mode, lhs, rhs, { ft = { 'csv', 'tsv' } })
      end,
    })
    view_toggle:map('<LocalLeader>t')

    -- Add Find Lines Keymap that disable view first
    snacks.keymap.set('n', '<LocalLeader>s', function()
      local bufnr = vim.api.nvim_get_current_buf()
      if csvview.is_enabled(bufnr) then
        csvview.disable()
      end
      snacks.picker.lines({
        layout = 'dropdown',
        on_close = function(picker)
          csvview.enable(bufnr)
        end,
      })
    end, {
      desc = 'Search',
      ft = { 'csv', 'tsv' },
    })
  end,
  dependencies = { 'folke/snacks.nvim' },
}
