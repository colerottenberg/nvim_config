-- Colorschemes. catppuccin (the default) loads at startup and applies the
-- cached colorscheme; every other theme is lazy -- lazy.nvim auto-loads a
-- theme plugin when its colorscheme is requested via :colorscheme / pickers.

local cache_file = vim.fn.stdpath('state') .. '/last_colorscheme'

return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {
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
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)

      -- Persist the colorscheme on change.
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('user_cache_colorscheme', { clear = true }),
        callback = function(args)
          pcall(function()
            local f = io.open(cache_file, 'w')
            if f then
              f:write(args.match)
              f:close()
            end
          end)
        end,
      })

      -- Apply the cached colorscheme, falling back to the default.
      local colorscheme = 'catppuccin-macchiato'
      local f = io.open(cache_file, 'r')
      if f then
        local cached = vim.trim(f:read('*a') or '')
        f:close()
        if cached ~= '' then
          colorscheme = cached
        end
      end
      if not pcall(vim.cmd.colorscheme, colorscheme) then
        pcall(vim.cmd.colorscheme, 'catppuccin-macchiato')
      end
    end,
  },

  { 'folke/tokyonight.nvim', lazy = true, opts = {} },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'thesimonho/kanagawa-paper.nvim', lazy = true, opts = {} },
  { 'rose-pine/neovim', name = 'rose-pine', lazy = true },
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  {
    'EdenEast/nightfox.nvim',
    lazy = true,
    opts = {
      options = {
        module_default = false,
        modules = {
          aerial = true,
          cmp = true,
          ['dap-ui'] = true,
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
      groups = { all = { NormalFloat = { link = 'Normal' } } },
    },
  },
  { 'savq/melange-nvim', lazy = true },
  { 'zootedb0t/citruszest.nvim', lazy = true },
  { 'uloco/bluloco.nvim', lazy = true, dependencies = { 'rktjmp/lush.nvim' }, opts = {} },
  -- Using Lazy
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      -- Lua
      require('onedark').setup({
        -- Main options --
        style = 'dark', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
        transparent = false, -- Show/hide background
        term_colors = true, -- Change terminal color as per the selected theme style
        ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
        cmp_itemkind_reverse = true, -- reverse item kind highlights in cmp menu

        -- toggle theme style ---
        toggle_style_key = '<Leader>uc', -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
        toggle_style_list = { 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light' }, -- List of styles to toggle between

        -- Change code style ---
        -- Options are italic, bold, underline, none
        -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
        code_style = {
          comments = 'italic',
          keywords = 'bold',
          functions = 'bold',
          strings = 'none',
          variables = 'bold',
        },

        -- Lualine options --
        lualine = {
          transparent = false, -- lualine center bar transparency
        },

        -- Custom Highlights --
        colors = {}, -- Override default colors
        highlights = {}, -- Override highlight groups

        -- Plugins Config --
        diagnostics = {
          darker = false, -- darker colors for diagnostic
          undercurl = false, -- use undercurl instead of underline for diagnostics
          background = false, -- use background color for virtual text
        },
      })
    end,
  },
}
