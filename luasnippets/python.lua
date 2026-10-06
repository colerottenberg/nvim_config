-- Custom Python snippets. Loaded by luasnip.loaders.from_lua (luasnippets/ on the runtimepath).
-- Only fills gaps: friendly-snippets and vim-snippets already cover def/class/
-- try/with/match/comprehensions/ifmain/dataclass (`dcl`)/test (`test`)/
-- logging (`glog`)/__future__ (`fut`)/pdb, so none of those triggers are reused.

local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmt = require('luasnip.extras.fmt').fmt

return {
  -- Types --------------------------------------------------------------------
  s(
    { trig = 'enum', desc = 'Enum class' },
    fmt(
      'class {}({}):\n    {} = {}',
      { i(1, 'Name'), c(2, { t('Enum'), t('StrEnum'), t('IntEnum') }), i(3, 'MEMBER'), i(0, 'auto()') }
    )
  ),
  s(
    { trig = 'proto', desc = 'typing.Protocol' },
    fmt('class {}(Protocol):\n    def {}(self{}) -> {}: ...', { i(1, 'Name'), i(2, 'method'), i(3), i(0, 'None') })
  ),
  s({ trig = 'tchk', desc = 'if TYPE_CHECKING: block' }, fmt('if TYPE_CHECKING:\n    {}', { i(0) })),

  -- pytest -------------------------------------------------------------------
  s(
    { trig = 'pfix', desc = 'pytest fixture' },
    fmt('@pytest.fixture{}\ndef {}() -> {}:\n    {}', {
      c(1, { t(''), t('(scope="module")'), t('(scope="session")'), t('(autouse=True)') }),
      i(2, 'name'),
      i(3, 'None'),
      i(0),
    })
  ),
  s(
    { trig = 'pparam', desc = 'pytest.mark.parametrize' },
    fmt('@pytest.mark.parametrize(\n    "{}",\n    [\n        {}\n    ],\n)', { i(1, 'arg, expected'), i(0) })
  ),
  s(
    { trig = 'praises', desc = 'pytest.raises context' },
    fmt('with pytest.raises({}{}):\n    {}', {
      i(1, 'ValueError'),
      c(2, { t(''), sn(nil, fmt(', match="{}"', { i(1) })) }),
      i(0),
    })
  ),

  -- Debug --------------------------------------------------------------------
  s({ trig = 'bp', desc = 'breakpoint()' }, t('breakpoint()')),
}
