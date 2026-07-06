-- snacks.nvim: dashboard, picker, notifier, indent guides, zen, and the small
-- utility modules (bufdelete, rename, lazygit, git) used across the config.

-- Skip decorations on invalid or very large buffers.
local function not_large(bufnr)
  if not (vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "") then return false end
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  return not (ok and stats and stats.size > 1024 * 256)
end

local edit_config = function()
  local init = vim.fn.stdpath "config" .. "/init.lua"
  vim.cmd.cd(vim.fn.fnamemodify(init, ":h"))
  vim.cmd.edit(init)
end

require("snacks").setup {
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  image = { enabled = true, doc = { enabled = false } },
  picker = { enabled = true, ui_select = true },
  notifier = {
    enabled = true,
    icons = { debug = "", error = "", info = "", trace = "", warn = "" },
  },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = " ", key = "n", desc = "New File",     action = "<Leader>n" },
        { icon = " ", key = "f", desc = "Find File",    action = "<Leader>ff" },
        { icon = " ", key = "o", desc = "Recents",      action = "<Leader>fo" },
        { icon = " ", key = "w", desc = "Find Word",    action = "<Leader>fw" },
        { icon = " ", key = "s", desc = "Last Session", action = function() require("resession").load "last" end },
        { icon = " ", key = "c", desc = "Config",       action = edit_config },
        { icon = " ", key = "q", desc = "Quit",         action = "<Cmd>qa<CR>" },
      },
      header = table.concat({
        "██████   █████                   █████   █████  ███                 ",
        "▒▒██████ ▒▒███                   ▒▒███   ▒▒███  ▒▒▒                  ",
        " ▒███▒███ ▒███   ██████   ██████  ▒███    ▒███  ████  █████████████  ",
        " ▒███▒▒███▒███  ███▒▒███ ███▒▒███ ▒███    ▒███ ▒▒███ ▒▒███▒▒███▒▒███ ",
        " ▒███ ▒▒██████ ▒███████ ▒███ ▒███ ▒▒███   ███   ▒███  ▒███ ▒███ ▒███ ",
        " ▒███  ▒▒█████ ▒███▒▒▒  ▒███ ▒███  ▒▒▒█████▒    ▒███  ▒███ ▒███ ▒███ ",
        " █████  ▒▒█████▒▒██████ ▒▒██████     ▒▒███      █████ █████▒███ █████",
        "▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒▒   ▒▒▒▒▒▒       ▒▒▒      ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒ ▒▒▒▒▒",
      }, "\n"),
    },
    sections = {
      { section = "header", padding = 5 },
      { section = "keys",   gap = 1,    padding = 3 },
      -- Custom "startup" section: the built-in one requires lazy.nvim's stats,
      -- which this vim.pack config does not have. Report vim.pack plugin count
      -- and time since init.lua started instead.
      function()
        local start = vim.g.start_time
        local ms = start and math.floor(((vim.uv or vim.loop).hrtime() - start) / 1e5 + 0.5) / 10 or 0
        local count = #vim.pack.get()
        return {
          align = "center",
          text = {
            { "⚡ Neovim loaded ", hl = "footer" },
            { tostring(count), hl = "special" },
            { " plugins in ", hl = "footer" },
            { ms .. "ms", hl = "special" },
          },
        }
      end,
    },
  },
  indent = {
    enabled = true,
    indent = { char = "▏" },
    scope = { char = "▏" },
    filter = not_large,
    animate = { enabled = false },
  },
  scope = { enabled = true, filter = not_large },
  words = { enabled = true, filter = not_large },
  zen = {
    toggles = { dim = false, diagnostics = false, inlay_hints = false },
  },
}

-- Small toggles / helpers that were in AstroNvim's snacks keymaps.
vim.keymap.set("n", "<Leader>h", function() require("snacks").dashboard.open() end, { desc = "Dashboard" })
vim.keymap.set("n", "<Leader>uD", function() require("snacks").notifier.hide() end, { desc = "Dismiss notifications" })
vim.keymap.set(
  "n",
  "<Leader>u|",
  function() require("snacks").toggle.indent():toggle() end,
  { desc = "Toggle indent guides" }
)
vim.keymap.set("n", "]r", function() require("snacks").words.jump(vim.v.count1) end, { desc = "Next reference" })
vim.keymap.set("n", "[r", function() require("snacks").words.jump(-vim.v.count1) end, { desc = "Previous reference" })
