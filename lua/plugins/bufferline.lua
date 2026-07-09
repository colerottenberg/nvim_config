-- Buffer tabs (shown in the tabline).

local function cycle(count)
  return function() require("bufferline.commands").cycle(count > 0 and vim.v.count1 or -vim.v.count1) end
end
local function move(count)
  return function() require("bufferline.commands").move(count > 0 and vim.v.count1 or -vim.v.count1) end
end

return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  cond = not vim.g.vscode,
  keys = {
    { "L", cycle(1), desc = "Next buffer" },
    { "H", cycle(-1), desc = "Previous buffer" },
    { "]b", cycle(1), desc = "Next buffer" },
    { "[b", cycle(-1), desc = "Previous buffer" },
    { ">b", move(1), desc = "Move buffer right" },
    { "<b", move(-1), desc = "Move buffer left" },
    { "<Leader>bc", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close all buffers except current" },
    { "<Leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Close buffers to the left" },
    { "<Leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Close buffers to the right" },
    { "<Leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin buffer" },
    { "<Leader>bb", "<Cmd>BufferLinePick<CR>", desc = "Pick buffer" },
    { "<Leader>bd", "<Cmd>BufferLinePickClose<CR>", desc = "Pick buffer to close" },
    { "<Leader>bse", "<Cmd>BufferLineSortByExtension<CR>", desc = "Sort by extension" },
    { "<Leader>bsr", "<Cmd>BufferLineSortByRelativeDirectory<CR>", desc = "Sort by relative path" },
    { "<Leader>bsp", "<Cmd>BufferLineSortByDirectory<CR>", desc = "Sort by full path" },
    { "<Leader>bsi", "<Cmd>BufferLineSortByTabs<CR>", desc = "Sort by tab" },
  },
  opts = {
    options = {
      offsets = {
        { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory", text_align = "left" },
      },
      diagnostics = "nvim_lsp",
    },
  },
}
