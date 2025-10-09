-- don't do anything in non-vscode instances
if not vim.g.vscode then return {} end

-- fixing vscode-neovim message output

---@type LazySpec
return {
  -- add a few keybindings
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        n = {
          L = { "<Cmd>Tabnext<CR>", desc = "Move to next tab" },
          H = { "<Cmd>Tabprevious<CR>", desc = "Move to previous tab" },
          ["<Leader>lS"] = { "<Cmd>call VSCodeNotify('outline.focus')<CR>", desc = "Symbol Outline" },
          ["<Leader>c"] = { "<Cmd>Tabclose<CR>", desc = "Close Tab" },
        },
      },
    },
  },
  -- disable colorscheme setting
  { "AstroNvim/astroui", opts = { colorscheme = false } },
  -- disable treesitter highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { highlight = { enable = false } },
  },
}
