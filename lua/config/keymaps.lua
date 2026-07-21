-- Global editor key mappings (plugin-independent).
--
-- Mappings whose action calls a plugin live in that plugin's lazy spec `keys`
-- (lua/plugins/*.lua) so they double as lazy-load triggers. LSP mappings are
-- applied on attach by config/lsp.lua.

local map = vim.keymap.set

-- ── Standard operations ───────────────────────────────────────────────────
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move cursor down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move cursor up" })
map("n", "<Leader>w", "<Cmd>w<CR>", { desc = "Save" })
map("n", "<Leader>q", "<Cmd>confirm q<CR>", { desc = "Quit window" })
map("n", "<Leader>Q", "<Cmd>confirm qall<CR>", { desc = "Quit all" })
map("n", "<Leader>n", "<Cmd>enew<CR>", { desc = "New file" })
map("n", "<C-S>", "<Cmd>silent! update! | redraw<CR>", { desc = "Force write" })
map("n", "<C-Q>", "<Cmd>q!<CR>", { desc = "Force quit" })
map("n", "|", "<Cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "\\", "<Cmd>split<CR>", { desc = "Horizontal split" })

-- Comments (gcc/gc are built in; add below/above helpers).
map("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
map("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment above" })

-- ── Package manager (lazy.nvim) ───────────────────────────────────────────
map("n", "<Leader>pi", function() require("lazy").install() end, { desc = "Plugins install" })
map("n", "<Leader>ps", function() require("lazy").home() end, { desc = "Plugins status" })
map("n", "<Leader>pS", function() require("lazy").sync() end, { desc = "Plugins sync" })
map("n", "<Leader>pu", function() require("lazy").check() end, { desc = "Plugins check updates" })
map("n", "<Leader>pU", function() require("lazy").update() end, { desc = "Plugins update" })
map("n", "<Leader>pm", "<Cmd>Mason<CR>", { desc = "Mason" })
map("n", "<Leader>pr", function() vim.cmd "restart" end, { desc = "Restart Neovim" })

-- ── Diagnostics / lists ───────────────────────────────────────────────────
local function diag_jump(count, severity)
  return function()
    vim.diagnostic.jump {
      count = count > 0 and vim.v.count1 or -vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
    }
  end
end
map("n", "]e", diag_jump(1, "ERROR"), { desc = "Next error" })
map("n", "[e", diag_jump(-1, "ERROR"), { desc = "Previous error" })
map("n", "]w", diag_jump(1, "WARN"), { desc = "Next warning" })
map("n", "[w", diag_jump(-1, "WARN"), { desc = "Previous warning" })
map("n", "]d", diag_jump(1), { desc = "Next diagnostic" })
map("n", "[d", diag_jump(-1), { desc = "Previous diagnostic" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Hover diagnostics" })
map("n", "<Leader>li", function() vim.cmd.checkhealth "vim.lsp" end, { desc = "LSP information" })
map("n", "<Leader>xq", "<Cmd>copen<CR>", { desc = "Quickfix list" })
map("n", "<Leader>xl", "<Cmd>lopen<CR>", { desc = "Location list" })

-- ── Tabs ──────────────────────────────────────────────────────────────────
map("n", "]t", function() vim.cmd.tabnext() end, { desc = "Next tab" })
map("n", "[t", function() vim.cmd.tabprevious() end, { desc = "Previous tab" })

-- Stay in indent mode when shifting a visual selection.
map("x", "<Tab>", ">gv", { desc = "Indent line" })
map("x", "<S-Tab>", "<gv", { desc = "Unindent line" })

-- Terminal window navigation (matches split navigation from smart-splits).
map("t", "<C-H>", "<Cmd>wincmd h<CR>", { desc = "Terminal left window navigation" })
map("t", "<C-J>", "<Cmd>wincmd j<CR>", { desc = "Terminal down window navigation" })
map("t", "<C-K>", "<Cmd>wincmd k<CR>", { desc = "Terminal up window navigation" })
map("t", "<C-L>", "<Cmd>wincmd l<CR>", { desc = "Terminal right window navigation" })

-- ── UI / UX toggles (<Leader>u*) ──────────────────────────────────────────
local function notify_toggle(name, value)
  vim.notify(("%s %s"):format(name, value and "enabled" or "disabled"), vim.log.levels.INFO)
end
map("n", "<Leader>uA", function()
  vim.o.autochdir = not vim.o.autochdir
  notify_toggle("autochdir", vim.o.autochdir)
end, { desc = "Toggle rooter autochdir" })
map("n", "<Leader>ub", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
  notify_toggle("background " .. vim.o.background, true)
end, { desc = "Toggle background" })
map("n", "<Leader>ud", function()
  local enabled = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(enabled)
  notify_toggle("diagnostics", enabled)
end, { desc = "Toggle diagnostics" })
map("n", "<Leader>ug", function()
  vim.wo.signcolumn = vim.wo.signcolumn == "no" and "yes" or "no"
  notify_toggle("signcolumn", vim.wo.signcolumn ~= "no")
end, { desc = "Toggle signcolumn" })
map("n", "<Leader>u>", function()
  vim.wo.foldcolumn = vim.wo.foldcolumn == "0" and "1" or "0"
  notify_toggle("foldcolumn", vim.wo.foldcolumn ~= "0")
end, { desc = "Toggle foldcolumn" })
map("n", "<Leader>ui", function()
  vim.bo.expandtab = not vim.bo.expandtab
  notify_toggle("expandtab", vim.bo.expandtab)
end, { desc = "Toggle expandtab" })
map("n", "<Leader>ul", function()
  vim.o.laststatus = vim.o.laststatus == 0 and 3 or 0
  notify_toggle("statusline", vim.o.laststatus ~= 0)
end, { desc = "Toggle statusline" })
map("n", "<Leader>un", function()
  vim.wo.number = not vim.wo.number
  notify_toggle("number", vim.wo.number)
end, { desc = "Toggle line numbers" })
map("n", "<Leader>ur", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
  notify_toggle("relativenumber", vim.wo.relativenumber)
end, { desc = "Toggle relative numbers" })
map("n", "<Leader>up", function()
  vim.o.paste = not vim.o.paste
  notify_toggle("paste", vim.o.paste)
end, { desc = "Toggle paste mode" })
map("n", "<Leader>us", function()
  vim.wo.spell = not vim.wo.spell
  notify_toggle("spell", vim.wo.spell)
end, { desc = "Toggle spellcheck" })
map("n", "<Leader>uS", function()
  vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
  notify_toggle("conceal", vim.wo.conceallevel ~= 0)
end, { desc = "Toggle conceal" })
map("n", "<Leader>uT", function()
  vim.o.showtabline = vim.o.showtabline == 0 and 2 or 0
  notify_toggle("tabline", vim.o.showtabline ~= 0)
end, { desc = "Toggle tabline" })
map("n", "<Leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  notify_toggle("wrap", vim.wo.wrap)
end, { desc = "Toggle wrap" })
map("n", "<Leader>uv", function()
  local cfg = vim.diagnostic.config()
  local enabled = not cfg.virtual_text
  vim.diagnostic.config { virtual_text = enabled }
  notify_toggle("virtual text", enabled)
end, { desc = "Toggle diagnostic virtual text" })
map("n", "<Leader>uV", function()
  local cfg = vim.diagnostic.config()
  local enabled = not cfg.virtual_lines
  vim.diagnostic.config { virtual_lines = enabled }
  notify_toggle("virtual lines", enabled)
end, { desc = "Toggle diagnostic virtual lines" })
map("n", "<Leader>uy", function()
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    pcall(vim.treesitter.start)
  end
end, { desc = "Toggle treesitter highlight (buffer)" })

-- K: value under cursor while debugging, otherwise LSP hover. Guarding on
-- `package.loaded.dap` avoids loading nvim-dap just by pressing K.
map("n", "K", function()
  local dap = package.loaded.dap
  if dap and dap.session() then
    require("dapui").eval(nil, { enter = false })
  else
    vim.lsp.buf.hover()
  end
end, { desc = "Hover symbol (value while debugging)" })

-- ── Type hierarchy (native vim.lsp) ───────────────────────────────────────
map("n", "<Leader>ly", "", { desc = "View Type Hierarchy" })
map("n", "<Leader>lyi", function() vim.lsp.buf.typehierarchy "subtypes" end, { desc = "View subtypes" })
map("n", "<Leader>lyo", function() vim.lsp.buf.typehierarchy "supertypes" end, { desc = "View supertypes" })
map("n", "ga", "", { desc = "View Calls" })
