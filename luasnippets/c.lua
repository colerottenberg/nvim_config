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

-- Lambda capture list choices: [&], [=], [this], [], or custom.
local function capture(pos)
  return c(pos, { t('&'), t('='), t('this'), t(''), i(nil, 'captures') })
end

-- Default the class name to the current file name.
local function filename()
  local name = vim.fn.expand('%:t:r')
  return sn(nil, i(1, name ~= '' and name or 'Name'))
end

return {
  -- Comments ------------------------------------------------------------------
  s(
    { trig = 'todo', desc = 'TODO-style comment' },
    fmt('// <> <>', {
      c(1, { t('TODO'), t('INFO'), t('WARN'), t('ERROR'), t('FIXME') }),
      i(2),
    }, { delimiters = '<>' })
  ),
}
