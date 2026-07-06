-- Global (non-LSP) key mappings.
--
-- Reproduces AstroNvim's default `_astrocore_mappings.lua` surface, with the
-- plugin-manager section retargeted to `vim.pack`, and layers on the mappings
-- from the old `lua/plugins/astrocore.lua`. LSP mappings live in
-- `config/lsp.lua` (set on attach). Plugin-owned keys (dap, jj, blame,
-- transparent, overseer, lazydocker, toggleterm) live in their own modules.

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
map("n", "<Leader>R", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.rename then
    snacks.rename.rename_file()
  else
    vim.notify("snacks.rename not available", vim.log.levels.WARN)
  end
end, { desc = "Rename file" })

-- Comments (gcc/gc are built in; add below/above helpers).
map("n", "<Leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
map("x", "<Leader>/", "gc", { remap = true, desc = "Toggle comment" })
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add comment above" })

-- ── Package manager (vim.pack) ────────────────────────────────────────────
map("n", "<Leader>pu", function() vim.pack.update() end, { desc = "Update plugins" })
map("n", "<Leader>pU", function() vim.pack.update() end, { desc = "Update all plugins" })
map("n", "<Leader>ps", function()
  local names = vim.tbl_map(function(p) return p.spec.name end, vim.pack.get())
  table.sort(names)
  vim.notify(table.concat(names, "\n"), vim.log.levels.INFO, { title = "Installed plugins (" .. #names .. ")" })
end, { desc = "Plugins status" })
map("n", "<Leader>pm", "<Cmd>Mason<CR>", { desc = "Mason" })

-- ── Buffers ───────────────────────────────────────────────────────────────
-- Bufferline cycling (H/L and ]b/[b), matching the old astrocore overrides.
map("n", "L", function() require("bufferline.commands").cycle(vim.v.count1) end, { desc = "Next buffer" })
map("n", "H", function() require("bufferline.commands").cycle(-vim.v.count1) end, { desc = "Previous buffer" })
map("n", "]b", function() require("bufferline.commands").cycle(vim.v.count1) end, { desc = "Next buffer" })
map("n", "[b", function() require("bufferline.commands").cycle(-vim.v.count1) end, { desc = "Previous buffer" })
map("n", ">b", function() require("bufferline.commands").move(vim.v.count1) end, { desc = "Move buffer right" })
map("n", "<b", function() require("bufferline.commands").move(-vim.v.count1) end, { desc = "Move buffer left" })
map("n", "<Leader>c", function() require("snacks").bufdelete() end, { desc = "Close buffer" })
map("n", "<Leader>C", function() require("snacks").bufdelete { force = true } end, { desc = "Force close buffer" })
map("n", "<Leader>bc", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Close all buffers except current" })
map("n", "<Leader>bC", function() require("snacks").bufdelete.all() end, { desc = "Close all buffers" })
map("n", "<Leader>bl", "<Cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
map("n", "<Leader>br", "<Cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })
map("n", "<Leader>bp", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle pin buffer" })
map("n", "<Leader>bb", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
map("n", "<Leader>bd", "<Cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" })
map("n", "<Leader>bse", "<Cmd>BufferLineSortByExtension<CR>", { desc = "Sort by extension" })
map("n", "<Leader>bsr", "<Cmd>BufferLineSortByRelativeDirectory<CR>", { desc = "Sort by relative path" })
map("n", "<Leader>bsp", "<Cmd>BufferLineSortByDirectory<CR>", { desc = "Sort by full path" })
map("n", "<Leader>bsi", "<Cmd>BufferLineSortByTabs<CR>", { desc = "Sort by tab" })

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
map("n", "<Leader>x", "", { desc = "Quickfix/Lists" })
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
map("n", "<Leader>ut", function()
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

-- ── DAP function keys (VS Code style) ─────────────────────────────────────
-- Terminals send Shift+F5/F11 either as <F17>/<F23> (legacy xterm) or
-- <S-F5>/<S-F11> (kitty/CSI-u); bind both. See docs/dap-guide.md.
map("n", "<F5>", function() require("dap").continue() end, { desc = "Debugger: continue / start" })
map("n", "<F6>", function() require("dap").pause() end, { desc = "Debugger: pause" })
map("n", "<F9>", function() require("dap").toggle_breakpoint() end, { desc = "Debugger: toggle breakpoint" })
map("n", "<F10>", function() require("dap").step_over() end, { desc = "Debugger: step over" })
map("n", "<F11>", function() require("dap").step_into() end, { desc = "Debugger: step into" })
map("n", "<F17>", function() require("dap").terminate() end, { desc = "Debugger: terminate (Shift+F5)" })
map("n", "<S-F5>", function() require("dap").terminate() end, { desc = "Debugger: terminate" })
map("n", "<F23>", function() require("dap").step_out() end, { desc = "Debugger: step out (Shift+F11)" })
map("n", "<S-F11>", function() require("dap").step_out() end, { desc = "Debugger: step out" })

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

-- ── LSP pickers / hierarchy (snacks) ──────────────────────────────────────

---@param name string
---@param cfg? snacks.picker.Config
local function snacks_picker(name, cfg)
  return function() require("snacks.picker")[name](cfg or { focus = "input" }) end
end
local function add_workspace_folder(picker, item)
  picker:close()
  if item and item.path then
    vim.lsp.buf.add_workspace_folder(item.path)
    require("snacks.notify").info("Added workspace folder: " .. item.path, { title = "LSP Workspace" })
  end
end
map("n", "<Leader>ly", "", { desc = "View Type Hierarchy" })
map("n", "<Leader>lyi", function() vim.lsp.buf.typehierarchy "subtypes" end, { desc = "View subtypes" })
map("n", "<Leader>lyo", function() vim.lsp.buf.typehierarchy "supertypes" end, { desc = "View supertypes" })
map("n", "ga", "", { desc = "View Calls" })
map("n", "gai", snacks_picker("lsp_incoming_calls", { focus = "list" }), { desc = "Incoming calls" })
map("n", "gao", snacks_picker "lsp_outgoing_calls", { desc = "Outgoing calls" })
map(
  "n",
  "gw",
  function() require("snacks.picker").projects { confirm = add_workspace_folder } end,
  { desc = "Add workspace folder" }
)
map("n", "gR", snacks_picker "lsp_references", { desc = "LSP references" })
map("n", "<Leader>ls", snacks_picker "lsp_symbols", { desc = "Search symbols" })
map("n", "<Leader>lR", snacks_picker "lsp_references", { desc = "LSP references" })
map(
  "n",
  "<Leader>lW",
  function() require("snacks.picker").projects { confirm = add_workspace_folder } end,
  { desc = "Add workspace folder" }
)
map("n", "<Leader>lc", function() require("snacks.picker").lsp_config() end, { desc = "LSP config" })
map(
  "n",
  "<Leader>lg",
  function() require("snacks.picker").lsp_workspace_symbols() end,
  { desc = "Search workspace symbols" }
)
map("n", "<Leader>ld", snacks_picker("diagnostics", { focus = "list" }), { desc = "Search diagnostics" })

-- ── Find (snacks pickers) ─────────────────────────────────────────────────
map("n", "<Leader>ft", snacks_picker("colorschemes", { focus = "list", layout = "ivy" }), { desc = "Find themes" })
map("n", "<Leader>fb", snacks_picker "buffers", { desc = "Find buffers" })
map("n", "<Leader>ff", snacks_picker "files", { desc = "Find files" })
map("n", "<Leader>fF", snacks_picker("files", { hidden = true, ignored = true }), { desc = "Find all files" })
map("n", "<Leader>fg", snacks_picker "git_files", { desc = "Find git files" })
map("n", "<Leader>fw", snacks_picker "grep", { desc = "Find words" })
map("n", "<Leader>fl", snacks_picker "lines", { desc = "Find lines" })
map("n", "<Leader>fc", snacks_picker "grep_word", { desc = "Find word under cursor" })
map("n", "<Leader>fo", snacks_picker "recent", { desc = "Find recent files" })
map("n", "<Leader>fh", snacks_picker "help", { desc = "Find help" })
map("n", "<Leader>fk", snacks_picker "keymaps", { desc = "Find keymaps" })
map("n", "<Leader>fm", snacks_picker "man", { desc = "Find man pages" })
map("n", "<Leader>fr", snacks_picker "registers", { desc = "Find registers" })
map("n", "<Leader>fC", snacks_picker "commands", { desc = "Find commands" })
map("n", "<Leader>fn", snacks_picker "notifications", { desc = "Find notifications" })
map("n", "<Leader>f<CR>", snacks_picker "resume", { desc = "Resume last picker" })

-- ── Git (snacks + gitsigns) ───────────────────────────────────────────────
map("n", "<Leader>gc", snacks_picker "git_log", { desc = "Git commits (repository)" })
map(
  "n",
  "<Leader>gC",
  snacks_picker("git_log", { focus = "list", current_file = true, follow = true }),
  { desc = "Git commits (file)" }
)
map("n", "<Leader>gb", snacks_picker "git_branches", { desc = "Git branches" })
map("n", "<Leader>gM", snacks_picker "git_log_line", { desc = "Git log line" })
map("n", "<Leader>gP", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
map("n", "<Leader>gg", function() require("snacks").lazygit() end, { desc = "Lazygit" })

-- ── Zen mode (dynamic width) ──────────────────────────────────────────────
map("n", "<Leader>uZ", function()
  local dynamic_width = math.floor(vim.o.columns * 0.7)
  dynamic_width = math.max(80, math.min(dynamic_width, 150))
  require("snacks.zen").zen {
    toggles = {},
    show = { tabline = true, statusline = true },
    win = { width = dynamic_width },
    center = true,
  }
end, { desc = "Zen mode (centered)" })

---── Reload ───────────────────────────────────────────────────────────
map("n", "<Leader>pr", function() vim.cmd "restart" end, { desc = "Restart Neovim" })
