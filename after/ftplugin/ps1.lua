local function map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = true, silent = true, desc = desc })
end

local function vmap(lhs, rhs, desc)
  vim.keymap.set({ 'n', 'x' }, lhs, rhs, { buffer = true, silent = true, desc = desc })
end

local ps = require('powershell')

map('<LocalLeader>t', function()
  ps.toggle_term()
end, 'PowerShell Term')
vmap('<LocalLeader>e', function()
  ps.eval()
end, 'Eval')
