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
  { 'nyoom-engineering/oxocarbon.nvim', lazy = true },
  { 'savq/melange-nvim', lazy = true },
  { 'zootedb0t/citruszest.nvim', lazy = true },
  { 'uloco/bluloco.nvim', lazy = true, dependencies = { 'rktjmp/lush.nvim' }, opts = {} },
}
