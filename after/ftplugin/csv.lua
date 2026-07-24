local CsvView = require('csvview')
local function map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = true, silent = true, desc = desc })
end

map('<LocalLeader>e', function()
  CsvView.enable(nil, nil)
end, 'Enable CsvView')
map('<LocalLeader>d', function()
  CsvView.disable(nil)
end)
map('<LocalLeader>t', function()
  CsvView.toggle(nil, nil)
end, 'Disable CsvView')
map('<LocalLeader>b', function()
  CsvView.enable(nil, {
    view = {
      display_mode = 'border',
    },
  })
end, 'Use border view')
map('<LocalLeader>h', function()
  CsvView.enable(nil, {
    view = {
      display_mode = 'highlight',
    },
  })
end, 'Use highlight view')
