-- Statusline (replaces the AstroNvim heirline bar).
--
-- `theme = "auto"` recolors from the active colorscheme. Git diff is sourced
-- from gitsigns; symbols breadcrumb from aerial; task status from overseer.

local function diff_source()
  local gs = vim.b.gitsigns_status_dict
  if gs then return { added = gs.added, modified = gs.changed, removed = gs.removed } end
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  cond = not vim.g.vscode,
  opts = {
    options = {
      theme = "auto",
      globalstatus = true, -- single statusline (laststatus=3)
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { statusline = { "dashboard", "alpha", "snacks_dashboard" } },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        { "diff", source = diff_source },
        { "diagnostics", sources = { "nvim_diagnostic" } },
      },
      lualine_c = {
        { "filename", path = 1 },
        { "aerial", sep = " ) " },
      },
      lualine_x = {
        { "overseer" },
        { "lsp_status" },
        { "fileformat" },
        { "filetype" },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
    extensions = {
      "neo-tree",
      "toggleterm",
      "quickfix",
      "man",
      "aerial",
      "nvim-dap-ui",
      "overseer",
      "lazy",
      "mason",
    },
  },
}
