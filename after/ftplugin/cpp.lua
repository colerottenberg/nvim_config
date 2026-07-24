local function map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = true, silent = true, desc = desc })
end

-- Plugins
local snacks = require('snacks.picker')

---@type snacks.picker.lsp.symbols.Config
local input_config = {
  focus = 'input',
}
local refs = function()
  snacks.lsp_references(input_config)
end
local function sym()
  snacks.lsp_symbols(input_config)
end

local function class_symbols()
  ---@type snacks.picker.lsp.symbols.Config
  local config = {
    filter = {
      default = {
        'Class',
        'Method',
        'Function',
        'Constructor',
      },
    },
  }
  snacks.lsp_symbols(config)
end

-- Mappings
map('<LocalLeader>s', sym, 'View symbols')
map('<LocalLeader>c', class_symbols, 'View class symbols')
map('<LocalLeader>r', refs, 'references')
