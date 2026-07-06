-- Autopairs. Includes the config's custom rules (tex `$…$`, and an `a`/`a` rule
-- disabled for vim files) from the old user.lua.

local npairs = require "nvim-autopairs"
local Rule = require "nvim-autopairs.rule"
local cond = require "nvim-autopairs.conds"

npairs.setup {
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
}

npairs.add_rules({
  Rule("$", "$", { "tex", "latex" })
    :with_pair(cond.not_after_regex "%%")
    :with_pair(cond.not_before_regex("xxx", 3))
    :with_move(cond.none())
    :with_del(cond.not_after_regex "xx")
    :with_cr(cond.none()),
}, Rule("a", "a", "-vim"))

local autopairs_on = true
vim.keymap.set("n", "<Leader>ua", function()
  autopairs_on = not autopairs_on
  if autopairs_on then
    npairs.enable()
  else
    npairs.disable()
  end
  vim.notify("autopairs " .. (autopairs_on and "on" or "off"), vim.log.levels.INFO)
end, { desc = "Toggle autopairs" })
