-- Buffer tabs (shown in the tabline).
local function cycle(count)
  return function() require("bufferline.commands").cycle(count > 0 and vim.v.count1 or -vim.v.count1) end
end
local function move(count)
  return function() require("bufferline.commands").move(count > 0 and vim.v.count1 or -vim.v.count1) end
end

-- Theme-aware highlights: catppuccin integration when available,
-- otherwise just fix the fill to match the editor background.
local function build_highlights()
  local ok, ctp = pcall(require, "catppuccin.groups.integrations.bufferline")
  if ok then
    return ctp.get() -- newer catppuccin renamed this; use get_theme() if get() errors
  end
  return { fill = { bg = Snacks.util.color("Normal", "bg") } }
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
    { "<Leader>bc", vim.cmd.BufferLineCloseOthers, desc = "Close all buffers except current" },
    { "<Leader>bl", vim.cmd.BufferLineCloseLeft, desc = "Close buffers to the left" },
    { "<Leader>br", vim.cmd.BufferLineCloseRight, desc = "Close buffers to the right" },
    { "<Leader>bp", vim.cmd.BufferLineTogglePin, desc = "Toggle pin buffer" },
    { "<Leader>bb", vim.cmd.BufferLinePick, desc = "Pick buffer" },
    { "<Leader>bd", vim.cmd.BufferLinePickClose, desc = "Pick buffer to close" },
    { "<Leader>bse", vim.cmd.BufferLineSortByExtension, desc = "Sort by extension" },
    { "<Leader>bsr", vim.cmd.BufferLineSortByRelativeDirectory, desc = "Sort by relative path" },
    { "<Leader>bsp", vim.cmd.BufferLineSortByDirectory, desc = "Sort by full path" },
    { "<Leader>bsi", vim.cmd.BufferLineSortByTabs, desc = "Sort by tab" },
  },
  opts = function()
    return {
      highlights = build_highlights(),
      options = {
        offsets = {
          { filetype = "neo-tree", text = "Neo-tree", highlight = "Directory", text_align = "left" },
        },
        diagnostics = "nvim_lsp",
      },
    }
  end,
  config = function(_, opts) require("bufferline").setup(opts) end,
}
