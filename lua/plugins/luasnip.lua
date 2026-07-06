-- Snippet engine. friendly-snippets are lazy-loaded from vscode/snipmate/lua.

local luasnip = require "luasnip"

luasnip.config.setup {
  history = true,
  delete_check_events = "TextChanged",
  region_check_events = "CursorMoved",
}

luasnip.filetype_extend("javascript", { "javascriptreact" })

for _, loader in ipairs { "vscode", "snipmate", "lua" } do
  require("luasnip.loaders.from_" .. loader).lazy_load()
end
