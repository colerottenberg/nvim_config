-- Editor options.
--
-- These reproduce AstroNvim's `_astrocore_options.lua` baseline with this
-- config's own overrides already folded in (originally `lua/plugins/astrocore.lua`
-- `options.opt`): relativenumber off, wrap on, exrc on.

local opt = vim.opt
local g = vim.g

opt.backspace:append "nostop" -- don't stop backspace at insert
opt.breakindent = true -- wrap indent to match line start
opt.clipboard = "unnamedplus" -- connection to the system clipboard
opt.cmdheight = 0 -- hide command line unless needed
opt.completeopt = { "menu", "menuone", "noselect" } -- insert mode completion
opt.confirm = true -- prompt to save before destructive actions
opt.copyindent = true -- copy the previous indentation on autoindenting
opt.cursorline = true -- highlight the text line of the cursor
opt.diffopt:append { "algorithm:histogram", "linematch:60" } -- better diffs
opt.expandtab = true -- use spaces instead of tabs
opt.fillchars = { eob = " " } -- disable `~` on nonexistent lines
opt.ignorecase = true -- case insensitive searching
opt.infercase = true -- infer cases in keyword completion
opt.jumpoptions = {} -- apply no jumpoptions on startup
opt.laststatus = 3 -- global statusline
opt.linebreak = true -- wrap lines at 'breakat'
opt.mouse = "a" -- enable mouse support
opt.number = true -- show numberline
opt.preserveindent = true -- preserve indent structure as much as possible
opt.pumheight = 10 -- height of the pop up menu
opt.relativenumber = false -- (override) absolute line numbers
opt.scrolloff = 9 -- scrolloff configuration
opt.shiftround = true -- round indentation with `>`/`<` to shiftwidth
opt.shiftwidth = 0 -- use 'tabstop' for indentation width
opt.shortmess:append { s = true, I = true, c = true, C = true } -- fewer messages
opt.showmode = false -- mode is shown in the statusline instead
opt.showtabline = 2 -- always display tabline
opt.signcolumn = "yes" -- always show the sign column
opt.smartcase = true -- case sensitive when search has uppercase
opt.spell = false -- spellcheck off by default
opt.splitbelow = true -- open horizontal splits below
opt.splitright = true -- open vertical splits to the right
opt.tabclose = "uselast" -- go to last used tab when closing a tab
opt.tabstop = 2 -- number of spaces in a tab
opt.termguicolors = true -- enable 24-bit RGB color in the TUI
opt.timeoutlen = 500 -- shorten key timeout a little for which-key
opt.title = true -- set terminal title to the filename and path
opt.undofile = true -- enable persistent undo
opt.updatetime = 300 -- CursorHold / swap write delay
opt.virtualedit = "block" -- allow going past end of line in visual block
opt.winborder = "rounded" -- default floating window border
opt.wrap = true -- (override) wrap long lines
opt.writebackup = false -- don't make a backup before overwriting
opt.exrc = true -- (override) read project-local .nvim.lua / .exrc

g.markdown_recommended_style = 0

-- ── polish (formerly lua/polish.lua): Windows PowerShell shell ─────────────
-- selene: allow(undefined_variable)
if jit.os == "Windows" then
  local o = vim.o
  o.shell = vim.fn.executable "pwsh" == 1 and "pwsh" or "powershell"
  o.shellcmdflag =
    "-NoLogo -NoProfile -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  o.shellquote = ""
  o.shellxquote = ""
end
