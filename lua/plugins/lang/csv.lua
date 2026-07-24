-- CSV / TSV rendering. Buffer-local view keymaps live in after/ftplugin/csv.lua.

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
}
