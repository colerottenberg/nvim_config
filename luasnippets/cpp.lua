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
  -- Lambdas ------------------------------------------------------------------
  s({ trig = 'lam', desc = 'Lambda' }, fmt('[<>](<>) {\n  <>\n}', { capture(1), i(2), i(0) }, { delimiters = '<>' })),
  s(
    { trig = 'lamr', desc = 'Lambda with trailing return type' },
    fmt('[<>](<>) ->> <> {\n  <>\n}', { capture(1), i(2), i(3, 'auto'), i(0) }, { delimiters = '<>' })
  ),
  s(
    { trig = 'laml', desc = 'Lambda assigned to a variable' },
    fmt('auto <> = [<>](<>) {\n  <>\n};', { i(1, 'fn'), capture(2), i(3), i(0) }, { delimiters = '<>' })
  ),
  s(
    { trig = 'lamm', desc = 'Mutable lambda' },
    fmt('[<>](<>) mutable {\n  <>\n}', { capture(1), i(2), i(0) }, { delimiters = '<>' })
  ),
  s(
    { trig = 'lamg', desc = 'Generic (templated) lambda' },
    fmt(
      '[<>]<<typename <>>>(<> <>) {\n  <>\n}',
      { capture(1), i(2, 'T'), rep(2), i(3, 'arg'), i(0) },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'iife', desc = 'Immediately invoked lambda' },
    fmt('const auto <> = [<>]() {\n  <>\n}();', { i(1, 'value'), capture(2), i(0) }, { delimiters = '<>' })
  ),

  -- Loops --------------------------------------------------------------------
  s(
    { trig = 'rfor', desc = 'Range-based for loop' },
    fmt(
      'for (<> <> : <>) {\n  <>\n}',
      { c(1, { t('const auto&'), t('auto&'), t('auto&&'), t('auto') }), i(2, 'item'), i(3, 'container'), i(0) },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'sfor', desc = 'Structured-binding for loop' },
    fmt(
      'for (const auto& [<>, <>] : <>) {\n  <>\n}',
      { i(1, 'key'), i(2, 'value'), i(3, 'map'), i(0) },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'ifor', desc = 'Indexed for loop' },
    fmt(
      'for (std::size_t <> = 0; <> << <>; ++<>) {\n  <>\n}',
      { i(1, 'i'), rep(1), i(2, 'n'), rep(1), i(0) },
      { delimiters = '<>' }
    )
  ),

  -- Classes & types ----------------------------------------------------------
  s(
    { trig = 'cls', desc = 'Class with constructor/destructor' },
    fmt(
      [[
class <> {
public:
  <>();
  ~<>();

private:
  <>
};]],
      { d(1, filename), rep(1), rep(1), i(0) },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'r5', desc = 'Rule of five declarations' },
    fmt(
      [[
<>(const <>&) = <>;
<>& operator=(const <>&) = <>;
<>(<>&&) noexcept = <>;
<>& operator=(<>&&) noexcept = <>;
~<>() = <>;]],
      {
        i(1, 'Name'),
        rep(1),
        c(2, { t('default'), t('delete') }),
        rep(1),
        rep(1),
        rep(2),
        rep(1),
        rep(1),
        c(3, { t('default'), t('delete') }),
        rep(1),
        rep(1),
        rep(3),
        rep(1),
        i(4, 'default'),
      },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'nocopy', desc = 'Delete copy operations' },
    fmt('<>(const <>&) = delete;\n<>& operator=(const <>&) = delete;', { i(1, 'Name'), rep(1), rep(1), rep(1) }, {
      delimiters = '<>',
    })
  ),
  s(
    { trig = 'enumc', desc = 'enum class' },
    fmt('enum class <> : <> {\n  <>\n};', { i(1, 'Name'), i(2, 'int'), i(0) }, { delimiters = '<>' })
  ),
  s(
    { trig = 'ns', desc = 'Namespace' },
    fmt('namespace <> {\n\n<>\n\n}  // namespace <>', { i(1, 'name'), i(0), rep(1) }, { delimiters = '<>' })
  ),

  -- Templates & concepts -----------------------------------------------------
  s({ trig = 'tmpl', desc = 'Template declaration' }, fmt('template <typename {}>', { i(1, 'T') })),
  s(
    { trig = 'concept', desc = 'C++20 concept' },
    fmt(
      'template <<typename <>>>\nconcept <> = requires(<> <>) {\n  <>\n};',
      { i(1, 'T'), i(2, 'Name'), rep(1), i(3, 't'), i(0) },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'sa', desc = 'static_assert' },
    fmt('static_assert(<>, "<>");', { i(1, 'cond'), i(2, 'message') }, { delimiters = '<>' })
  ),

  -- Smart pointers & casts ---------------------------------------------------
  s(
    { trig = 'uptr', desc = 'std::unique_ptr via make_unique' },
    fmt('auto <> = std::make_unique<<<>>>(<>);', { i(1, 'ptr'), i(2, 'T'), i(0) }, { delimiters = '<>' })
  ),
  s(
    { trig = 'sptr', desc = 'std::shared_ptr via make_shared' },
    fmt('auto <> = std::make_shared<<<>>>(<>);', { i(1, 'ptr'), i(2, 'T'), i(0) }, { delimiters = '<>' })
  ),
  s({ trig = 'scast', desc = 'static_cast' }, fmt('static_cast<<<>>>(<>)', { i(1, 'T'), i(2) }, { delimiters = '<>' })),
  s(
    { trig = 'dcast', desc = 'dynamic_cast' },
    fmt('dynamic_cast<<<>>>(<>)', { i(1, 'T*'), i(2) }, { delimiters = '<>' })
  ),
  s(
    { trig = 'rcast', desc = 'reinterpret_cast' },
    fmt('reinterpret_cast<<<>>>(<>)', { i(1, 'T*'), i(2) }, { delimiters = '<>' })
  ),

  -- Misc ---------------------------------------------------------------------
  s({ trig = 'all', desc = 'begin/end iterator pair' }, fmt('{}.begin(), {}.end()', { i(1, 'c'), rep(1) })),
  s(
    { trig = 'tc', desc = 'try/catch' },
    fmt(
      'try {\n  <>\n} catch (const <>& <>) {\n  <>\n}',
      { i(1), i(2, 'std::exception'), i(3, 'e'), i(0) },
      { delimiters = '<>' }
    )
  ),
  s(
    { trig = 'println', desc = 'std::println (C++23)' },
    fmt('std::println("<>"<>);', { i(1, '{}'), i(2) }, { delimiters = '<>' })
  ),
  s({ trig = 'once', desc = '#pragma once' }, t('#pragma once')),
  s(
    { trig = 'mainx', desc = 'main with argc/argv' },
    fmt('int main(int argc, char* argv[]) {\n  <>\n  return 0;\n}', { i(0) }, { delimiters = '<>' })
  ),
}
