-- snacks.nvim: dashboard, picker, notifier, indent guides, zen, and the small
-- utility modules (bufdelete, rename, lazygit, git) used across the config.
-- Not lazy: dashboard/bigfile/notifier must be active at startup.

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

---@param name string
---@param cfg? snacks.picker.Config
local function picker(name, cfg)
  return function() require("snacks.picker")[name](cfg or { focus = "input" }) end
end

local function add_workspace_folder(p, item)
  p:close()
  if item and item.path then
    vim.lsp.buf.add_workspace_folder(item.path)
    require("snacks.notify").info("Added workspace folder: " .. item.path, { title = "LSP Workspace" })
  end
end

local layouts = require "snacks.picker.config.layouts"

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 900,
  keys = {
    -- find
    { "<Leader>ft", picker("colorschemes", { focus = "list", layout = layouts.right }), desc = "Find themes" },
    { "<Leader>fb", picker "buffers", desc = "Find buffers" },
    { "<Leader>ff", picker "files", desc = "Find files" },
    { "<Leader>fF", picker("files", { hidden = true, ignored = true }), desc = "Find all files" },
    { "<Leader>fg", picker "git_files", desc = "Find git files" },
    { "<Leader>fw", picker "grep", desc = "Find words" },
    { "<Leader>fW", picker("grep", { hidden = true, ignored = true }), desc = "Find all words" },
    { "<Leader>fl", picker("lines", { layout = layouts.select }), desc = "Find lines" },
    {
      "<Leader>fc",
      picker "grep_word",
      desc = "Find word under cursor",
    },
    { "<Leader>fo", picker "recent", desc = "Find recent files" },
    { "<Leader>fh", picker "help", desc = "Find help" },
    { "<Leader>fk", picker "keymaps", desc = "Find keymaps" },
    { "<Leader>fm", picker "man", desc = "Find man pages" },
    { "<Leader>fr", picker "registers", desc = "Find registers" },
    { "<Leader>fC", picker "commands", desc = "Find commands" },
    {
      "<Leader>fn",
      picker "notifications",
      desc = "Find notifications",
    },
    {
      "<Leader>f<CR>",
      picker "resume",
      desc = "Resume last picker",
    },
    -- lists
    { "<Leader>x", picker("qflist", { focus = "list" }), desc = "Quickfix/Lists" },
    { "<C-q>", picker("qflist", { focus = "list" }), desc = "Quickfix/Lists" },
    -- LSP pickers / hierarchy
    { "gai", picker("lsp_incoming_calls", { focus = "list" }), desc = "Incoming calls" },
    { "gao", picker("lsp_outgoing_calls", { focus = "list" }), desc = "Outgoing calls" },
    {
      "gw",
      function() require("snacks.picker").projects { confirm = add_workspace_folder } end,
      desc = "Add workspace folder",
    },
    {
      "gR",
      picker("lsp_references", { focus = "list", formatters = { file = { filename_only = true } } }),
      desc = "LSP references",
    },
    {
      "<Leader>ls",
      picker "lsp_symbols",
      desc = "Search symbols",
    },
    {
      "<Leader>lS",
      picker("lsp_symbols", {
        focus = "list",
        tree = true,
        layout = layouts.right,
        auto_close = false,
        jump = {
          close = false,
        },
      }),
      desc = "Search symbols",
    },
    {
      "<Leader>lR",
      picker "lsp_references",
      desc = "LSP references",
    },
    {
      "<Leader>lW",
      function() require("snacks.picker").projects { confirm = add_workspace_folder } end,
      desc = "Add workspace folder",
    },
    { "<Leader>lc", function() require("snacks.picker").lsp_config() end, desc = "LSP config" },
    {
      "<Leader>lg",
      function() require("snacks.picker").lsp_workspace_symbols() end,
      desc = "Search workspace symbols",
    },
    { "<Leader>ld", picker("diagnostics", { focus = "list" }), desc = "Search diagnostics" },
    -- git
    { "<Leader>gc", picker "git_log", desc = "Git commits (repository)" },
    {
      "<Leader>gC",
      picker("git_log", { focus = "list", current_file = true, follow = true }),
      desc = "Git commits (file)",
    },
    { "<Leader>gb", picker "git_branches", desc = "Git branches" },
    { "<Leader>gM", picker "git_log_line", desc = "Git log line" },
    -- buffers
    { "<Leader>c", function() require("snacks").bufdelete() end, desc = "Close buffer" },
    { "<Leader>C", function() require("snacks").bufdelete { force = true } end, desc = "Force close buffer" },
    { "<Leader>bC", function() require("snacks").bufdelete.all() end, desc = "Close all buffers" },
    -- misc
    { "<Leader>R", function() require("snacks").rename.rename_file() end, desc = "Rename file" },
    { "<Leader>h", function() require("snacks").dashboard.open() end, desc = "Dashboard" },
    { "<Leader>uD", function() require("snacks").notifier.hide() end, desc = "Dismiss notifications" },
    { "<Leader>u|", function() require("snacks").toggle.indent():toggle() end, desc = "Toggle indent guides" },
    { "]r", function() require("snacks").words.jump(vim.v.count1) end, desc = "Next reference" },
    { "[r", function() require("snacks").words.jump(-vim.v.count1) end, desc = "Previous reference" },
    {
      "<Leader>uz",
      function() Snacks.zen() end,
      desc = "Zen mode (centered)",
    },
  },
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true, line_length = 5000, notify = true },
    quickfile = { enabled = true },
    ---@type snacks.input.Config
    input = { enabled = true },
    ---@type snacks.image.Config
    image = { enabled = true, doc = { enabled = false } },
    picker = { enabled = true, ui_select = true },
    notifier = {
      enabled = true,
      icons = { debug = "", error = "", info = "", trace = "", warn = "" },
    },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = "", key = "n", desc = "New File", action = "<Leader>n" },
          { icon = "󰱼", key = "f", desc = "Find File", action = "<Leader>ff" },
          { icon = "󱎸", key = "w", desc = "Find Word", action = "<Leader>fw" },
          { icon = "", key = "s", desc = "Last Session", action = function() require("resession").load "last" end },
          { icon = "", key = "c", desc = "Config", action = edit_config },
          {
            icon = "",
            key = "t",
            desc = "Themes",
            action = function() require("snacks.picker").colorschemes() end,
          },
          { icon = "", key = "q", desc = "Quit", action = "<Cmd>qa<CR>" },
        },
        header = table.concat({
          "██████╗  ██████╗ ████████╗████████╗███████╗███╗   ██╗██╗   ██╗██╗███╗   ███╗",
          "██╔══██╗██╔═══██╗╚══██╔══╝╚══██╔══╝██╔════╝████╗  ██║██║   ██║██║████╗ ████║",
          "██████╔╝██║   ██║   ██║      ██║   █████╗  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
          "██╔══██╗██║   ██║   ██║      ██║   ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
          "██║  ██║╚██████╔╝   ██║      ██║   ███████╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
          "╚═╝  ╚═╝ ╚═════╝    ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        }, "\n"),
      },
      sections = {
        { section = "header", padding = 5 },
        { section = "keys", gap = 1, padding = 3 },
        -- The built-in startup section works again under lazy.nvim.
        { section = "startup" },
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
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    local function backdrop_hl() vim.api.nvim_set_hl(0, "SnacksBackdrop", { bg = Snacks.util.color("Normal", "bg") }) end
    backdrop_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("snacks_backdrop_hl", { clear = true }),
      callback = backdrop_hl,
    })

    -- The dashboard hides the tabline/statusline, but bufferline and lualine
    -- load on VeryLazy (after the dashboard opened) and turn them back on.
    -- Re-hide once VeryLazy plugins are done; snacks restores them on close.
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      once = true,
      callback = function()
        if vim.bo.filetype == "snacks_dashboard" then
          vim.o.showtabline = 0
          vim.o.laststatus = 0
        end
      end,
    })
  end,
}
