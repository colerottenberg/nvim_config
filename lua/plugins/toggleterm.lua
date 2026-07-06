-- Terminal management.

require("toggleterm").setup {
  highlights = {
    Normal = { link = "Normal" },
    NormalNC = { link = "NormalNC" },
    NormalFloat = { link = "NormalFloat" },
    FloatBorder = { link = "FloatBorder" },
    StatusLine = { link = "StatusLine" },
    StatusLineNC = { link = "StatusLineNC" },
    WinBar = { link = "WinBar" },
    WinBarNC = { link = "WinBarNC" },
  },
  size = 10,
  shading_factor = 2,
  on_create = function(t)
    vim.opt_local.foldcolumn = "0"
    vim.opt_local.signcolumn = "no"
    if t.hidden then
      local function toggle() t:toggle() end
      vim.keymap.set({ "n", "t", "i" }, "<C-'>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
      vim.keymap.set({ "n", "t", "i" }, "<F7>", toggle, { desc = "Toggle terminal", buffer = t.bufnr })
    end
  end,
}

local Terminal = require("toggleterm.terminal").Terminal

-- Cached REPL/tool terminals so each toggles the same instance.
local terms = {}
local function toggle_cmd(key, opts)
  return function()
    if not terms[key] then terms[key] = Terminal:new(vim.tbl_extend("force", { hidden = true }, opts)) end
    terms[key]:toggle()
  end
end

local map = vim.keymap.set
map({ "n", "t", "i" }, "<F7>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map({ "n", "t", "i" }, "<C-'>", "<Cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("n", "<Leader>tf", "<Cmd>ToggleTerm direction=float<CR>", { desc = "Float terminal" })
map("n", "<Leader>th", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "Horizontal terminal" })
map("n", "<Leader>tv", "<Cmd>ToggleTerm size=80 direction=vertical<CR>", { desc = "Vertical terminal" })

if vim.fn.executable "lazygit" == 1 and vim.fn.executable "git" == 1 then
  local lazygit = toggle_cmd("lazygit", { cmd = "lazygit", direction = "float" })
  map("n", "<Leader>tl", lazygit, { desc = "ToggleTerm lazygit" })
  map("n", "<Leader>gg", lazygit, { desc = "ToggleTerm lazygit" })
end
if vim.fn.executable "node" == 1 then
  map("n", "<Leader>tn", toggle_cmd("node", { cmd = "node", direction = "float" }), { desc = "ToggleTerm node" })
end
if vim.fn.executable "python" == 1 or vim.fn.executable "python3" == 1 then
  local py = vim.fn.executable "python" == 1 and "python" or "python3"
  map("n", "<Leader>tp", toggle_cmd("python", { cmd = py, direction = "float" }), { desc = "ToggleTerm python" })
end
