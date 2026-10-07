-- Custom C++ snippets. Loaded by luasnip.loaders.from_lua (luasnippets/ on the runtimepath).

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require('luasnip.extras.fmt').fmt
local rep = require('luasnip.extras').rep

-- Default the class name to the current file name.
local function filename()
  local name = vim.fn.expand('%:t:r')
  return sn(nil, i(1, name ~= '' and name or 'Name'))
end

return {
  -- Custom ------------------------------------------------------------------
  s({ trig = 'type', desc = 'Type Alias' }, fmt('---@type <>', { i(1) }, { delimiters = '<>' })),
  s(
    { trig = 'cf', desc = 'Config Function' },
    fmt('config = function(_, opts)\n\t<>\nend', { i(1) }, { delimiters = '<>' })
  ),
}
