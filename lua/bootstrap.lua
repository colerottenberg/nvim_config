-- Plugin registration via Neovim's built-in plugin manager (`:h vim.pack`).
--
-- `vim.pack.add` installs (on first run, in parallel, blocking) and puts every
-- plugin on the runtimepath. Actual configuration happens in `lua/plugins/*`.
-- Repos whose basename is generic (`nvim`, `neovim`) get an explicit `name` so
-- they land in a sensibly named directory and never collide.

local range = vim.version.range

---@type (string|vim.pack.Spec)[]
local specs = {
  -- ── Libraries / shared dependencies ─────────────────────────────────────
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/rktjmp/lush.nvim" },
  { src = "https://github.com/nvim-mini/mini.icons" },

  -- ── Colorschemes ────────────────────────────────────────────────────────
  { src = "https://github.com/catppuccin/nvim",                             name = "catppuccin" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/rebelot/kanagawa.nvim" },
  { src = "https://github.com/thesimonho/kanagawa-paper.nvim" },
  { src = "https://github.com/rose-pine/neovim",                            name = "rose-pine" },
  { src = "https://github.com/ellisonleao/gruvbox.nvim" },
  { src = "https://github.com/EdenEast/nightfox.nvim" },
  { src = "https://github.com/nyoom-engineering/oxocarbon.nvim" },
  { src = "https://github.com/savq/melange-nvim" },
  { src = "https://github.com/zootedb0t/citruszest.nvim" },
  { src = "https://github.com/uloco/bluloco.nvim" },

  -- ── UI ──────────────────────────────────────────────────────────────────
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/stevearc/aerial.nvim" },
  { src = "https://github.com/stevearc/resession.nvim" },
  { src = "https://github.com/mrjones2014/smart-splits.nvim" },
  { src = "https://github.com/akinsho/toggleterm.nvim" },
  { src = "https://github.com/s1n7ax/nvim-window-picker" },
  { src = "https://github.com/xiyaowong/transparent.nvim" },

  -- ── Editing ─────────────────────────────────────────────────────────────
  { src = "https://github.com/windwp/nvim-autopairs" },
  { src = "https://github.com/NMAC427/guess-indent.nvim" },
  { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },

  -- ── Completion / snippets ───────────────────────────────────────────────
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/saghen/blink.cmp",                            version = range "1" },
  { src = "https://github.com/saghen/blink.compat" },
  { src = "https://github.com/folke/lazydev.nvim" },

  -- ── Treesitter (main branch) ────────────────────────────────────────────
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",             version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/windwp/nvim-ts-autotag" },

  -- ── LSP / Mason ─────────────────────────────────────────────────────────
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/jay-babu/mason-nvim-dap.nvim" },

  -- ── DAP ─────────────────────────────────────────────────────────────────
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  { src = "https://github.com/rcarriga/cmp-dap" },

  -- ── Language packs ──────────────────────────────────────────────────────
  { src = "https://github.com/p00f/clangd_extensions.nvim" },
  { src = "https://github.com/Civitasv/cmake-tools.nvim" },
  { src = "https://github.com/mrcjkb/rustaceanvim",                         version = range "^9" },
  { src = "https://github.com/Saecki/crates.nvim" },
  { src = "https://github.com/nvim-java/nvim-java" },
  { src = "https://github.com/JavaHello/spring-boot.nvim" },
  { src = "https://github.com/hat0uma/csvview.nvim" },

  -- ── Git / VCS ───────────────────────────────────────────────────────────
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/FabijanZulj/blame.nvim" },

  -- ── Tasks / tools ───────────────────────────────────────────────────────
  { src = "https://github.com/stevearc/overseer.nvim" },
  { src = "https://github.com/mgierada/lazydocker.nvim" },

  -- ── AI ──────────────────────────────────────────────────────────────────
  { src = "https://github.com/yetone/avante.nvim" },
  { src = "https://github.com/Kaiser-Yang/blink-cmp-avante" },
  { src = "https://github.com/zbirenbaum/copilot.lua" },
  { src = "https://github.com/HakonHarnes/img-clip.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/stevearc/dressing.nvim" },
  { src = "https://github.com/nvim-mini/mini.pick" },

  -- ── Misc integrations ───────────────────────────────────────────────────
  { src = "https://github.com/ray-x/lsp_signature.nvim" },
  { src = "https://github.com/andweeb/presence.nvim" },
}

vim.pack.add(specs, { load = true })

-- ── Post-install / post-update build steps ────────────────────────────────
-- vim.pack fires `PackChanged` after a plugin's state changes. Run each
-- plugin's native build only on install/update, not on every startup.
local builds = {
  ["LuaSnip"] = { "make", "install_jsregexp" },
  ["avante.nvim"] = { "make" },
}

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack_build_hooks", { clear = true }),
  callback = function(ev)
    local data = ev.data
    if data.kind ~= "install" and data.kind ~= "update" then return end
    local cmd = builds[data.spec.name]
    if not cmd then return end
    if data.spec.name == "LuaSnip" and vim.fn.has "win32" == 1 then return end
    vim.notify(("Building %s: %s"):format(data.spec.name, table.concat(cmd, " ")), vim.log.levels.INFO)
    vim.system(cmd, { cwd = data.path }, function(out)
      local level = out.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      vim.schedule(
        function()
          vim.notify(
            ("%s build %s"):format(data.spec.name, out.code == 0 and "succeeded" or "failed:\n" .. (out.stderr or "")),
            level
          )
        end
      )
    end)
  end,
})
