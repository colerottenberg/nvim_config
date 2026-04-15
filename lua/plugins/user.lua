-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- Transparent
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
        "LspInlayHint",
        "WinBar",
        "WinBarNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "NormalFloat",
        "FloatBorder",
        "FloatTitle",
        "RenderMarkdownCode",
      },
    },
    config = function(_, opts)
      local transparent = require "transparent"
      transparent.setup(opts)
      transparent.clear_prefix "BufferLine"
      transparent.clear_prefix "NeoTree"
      transparent.clear_prefix "lualine"
    end,
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          opts.mappings.n["<Leader>uT"] = { "<Cmd>TransparentToggle<CR>", desc = "Toggle transparency" }
          if vim.tbl_get(opts, "autocmds", "heirline_colors") then
            table.insert(opts.autocmds.heirline_colors, {
              event = "User",
              pattern = "TransparentClear",
              desc = "Refresh heirline colors",
              callback = function()
                if package.loaded["heirline"] then require("astroui.status.heirline").refresh_colors() end
              end,
            })
          end
        end,
      },
    },
  },

  -- Colorschemes
  { "zootedb0t/citruszest.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  {
    "EdenEast/nightfox.nvim",
    opts = {
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
    },
  },
  { "nyoom-engineering/oxocarbon" },
  { "savq/melange-nvim" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { "rose-pine/neovim", name = "rose-pine" },
  { "rebelot/kanagawa.nvim", lazy = true },
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },

  -- Adding Git Blame
  {
    "FabijanZulj/blame.nvim",
    cmd = "BlameToggle",
    opts = {},
    dependencies = {
      {
        "AstroNvim/astrocore",
        ---@type AstroCoreOpts
        opts = {
          mappings = {
            n = {
              ["<Leader>gB"] = {
                "<cmd>BlameToggle<cr>",
                desc = "Toggle git blame",
              },
            },
          },
        },
      },
      { "AstroNvim/astroui", opts = { status = { winbar = { enabled = { filetype = { "blame" } } } } } },
    },
  },

  -- == Examples of Overriding Plugins ==

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
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
      },
    },
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })

      -- include the default astronvim config that calls the setup call
      require "astronvim.plugins.configs.luasnip"(plugin, opts)
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
}
