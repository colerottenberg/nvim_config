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
  { import = "astrocommunity.pack.go" },
  -- cli tool helpers
  { import = "astrocommunity.docker.lazydocker" },
  -- colorschemes
  -- recipes for things such as Neovim VSCode Configuration
  { import = "astrocommunity.recipes.vscode" },
  -- import/override with your plugins folder
}
