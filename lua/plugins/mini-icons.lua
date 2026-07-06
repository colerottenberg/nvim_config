-- mini.icons as the icon provider, mocking nvim-web-devicons so plugins that
-- expect devicons keep working.

require("mini.icons").setup {}
-- selene: allow(undefined_variable)
MiniIcons.mock_nvim_web_devicons()
