-- Buffer tabs (shown in the tabline). Keymaps (H/L, ]b/[b, <Leader>b*) live in
-- config/keymaps.lua.

require("bufferline").setup {
  options = {
    offsets = {
      { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory", text_align = "left" },
    },
    diagnostics = "nvim_lsp",
  },
}
