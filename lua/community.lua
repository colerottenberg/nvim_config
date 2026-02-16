-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- packs
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.go" },
  -- cli tool helpers
  { import = "astrocommunity.docker.lazydocker" },
  -- colorschemes
  { import = "astrocommunity.colorscheme.oxocarbon-nvim" },
  { import = "astrocommunity.colorscheme.bluloco-nvim" },
  { import = "astrocommunity.color.transparent-nvim" },
  -- icons
  { import = "astrocommunity.icon.mini-icons" },
  -- recipes for things such as Neovim VSCode Configuration
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
  { import = "astrocommunity.recipes.cache-colorscheme" },
  -- Adding avante
  -- { import = "astrocommunity.completion.avante-nvim" },
}
