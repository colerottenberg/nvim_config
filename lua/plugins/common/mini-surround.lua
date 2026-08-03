return {
  'nvim-mini/mini.surround',
  version = false,
  config = function()
    local s = require('mini.surround')
    s.setup(nil)
  end,
}
