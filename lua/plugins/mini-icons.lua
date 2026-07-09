-- mini.icons as the icon provider, mocking nvim-web-devicons so plugins that
-- expect devicons keep working even before mini.icons itself is loaded.

return {
  "nvim-mini/mini.icons",
  lazy = true,
  opts = {},
  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
}
