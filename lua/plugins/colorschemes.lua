-- Colorschemes + colorscheme caching (replaces astrocommunity cache-colorscheme).
--
-- Configures the themes that need setup opts, remembers the last colorscheme
-- across sessions, and applies it (default: catppuccin-macchiato, formerly the
-- astroui `colorscheme`).

local cache_file = vim.fn.stdpath "state" .. "/last_colorscheme"

-- catppuccin
require("catppuccin").setup {
  integrations = {
    aerial = true,
    blink_cmp = true,
    dap = true,
    dap_ui = true,
    gitsigns = true,
    mason = true,
    native_lsp = { enabled = true },
    neotree = true,
    notifier = true,
    overseer = true,
    render_markdown = true,
    snacks = true,
    treesitter = true,
    which_key = true,
  },
}

-- nightfox
require("nightfox").setup {
  options = {
    module_default = false,
    modules = {
      aerial = true,
      cmp = true,
      ["dap-ui"] = true,
      dashboard = true,
      diagnostic = true,
      gitsigns = true,
      native_lsp = true,
      neotree = true,
      notify = true,
      symbol_outline = true,
      telescope = true,
      treesitter = true,
      whichkey = true,
    },
  },
  groups = { all = { NormalFloat = { link = "Normal" } } },
}

-- themes that take an opts table
require("tokyonight").setup {}
require("kanagawa-paper").setup {}
require("bluloco").setup {}

-- Persist the colorscheme on change.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user_cache_colorscheme", { clear = true }),
  callback = function(args)
    pcall(function()
      local f = io.open(cache_file, "w")
      if f then
        f:write(args.match)
        f:close()
      end
    end)
  end,
})

-- Apply the cached colorscheme, falling back to the default.
local colorscheme = "catppuccin-macchiato"
local f = io.open(cache_file, "r")
if f then
  local cached = vim.trim(f:read "*a" or "")
  f:close()
  if cached ~= "" then colorscheme = cached end
end
if not pcall(vim.cmd.colorscheme, colorscheme) then pcall(vim.cmd.colorscheme, "catppuccin-macchiato") end
