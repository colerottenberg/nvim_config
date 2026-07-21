-- Autopairs. Includes the config's custom rules (tex `$…$`, and an `a`/`a` rule
-- disabled for vim files).

return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  keys = {
    {
      "<Leader>ua",
      function()
        local npairs = require "nvim-autopairs"
        if npairs.state.disabled then
          npairs.enable()
        else
          npairs.disable()
        end
        vim.notify("autopairs " .. (npairs.state.disabled and "off" or "on"), vim.log.levels.INFO)
      end,
      desc = "Toggle autopairs",
    },
  },
  opts = {
    check_ts = true,
    ts_config = { java = false },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      offset = 0,
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "PmenuSel",
      highlight_grey = "LineNr",
    },
  },
  config = function(_, opts)
    local npairs = require "nvim-autopairs"
    local Rule = require "nvim-autopairs.rule"
    local cond = require "nvim-autopairs.conds"

    npairs.setup(opts)

    npairs.add_rules({
      Rule("$", "$", { "tex", "latex" })
        :with_pair(cond.not_after_regex "%%")
        :with_pair(cond.not_before_regex("xxx", 3))
        :with_move(cond.none())
        :with_del(cond.not_after_regex "xx")
        :with_cr(cond.none()),
    }, Rule("a", "a", "-vim"))
  end,
}
