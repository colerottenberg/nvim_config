-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- packs
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.cpp" },
  -- { import = "astrocommunity.pack.java" }, -- broken on work machine
  -- markdown / latex
  -- { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
  -- { import = "astrocommunity.markdown-and-latex.vimtex" },
  -- cli tool helpers
  { import = "astrocommunity.docker.lazydocker" },
  -- colorschemes
  { import = "astrocommunity.colorscheme.oxocarbon-nvim" },
  { import = "astrocommunity.colorscheme.rose-pine" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  { import = "astrocommunity.colorscheme.nord-nvim" },
  { import = "astrocommunity.colorscheme.melange-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- recipes for things such as Neovim VSCode Configuration
  { import = "astrocommunity.recipes.vscode" },
  -- import/override with your plugins folder
}
