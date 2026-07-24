-- Statusline (replaces the AstroNvim heirline bar).
--
-- `theme = "auto"` recolors from the active colorscheme. Git diff is sourced
-- from gitsigns; symbols breadcrumb from aerial; task status from overseer.

local function diff_source()
  local gs = vim.b.gitsigns_status_dict
  if gs then
    return { added = gs.added, modified = gs.changed, removed = gs.removed }
  end
end

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  cond = not vim.g.vscode,
  ---@class LualineSectionTable
  ---@field lualine_a? (string|table|fun():string)[]
  ---@field lualine_b? (string|table|fun():string)[]
  ---@field lualine_c? (string|table|fun():string)[]
  ---@field lualine_x? (string|table|fun():string)[]
  ---@field lualine_y? (string|table|fun():string)[]
  ---@field lualine_z? (string|table|fun():string)[]

  ---@class LualineConfig
  ---@field options? {theme?: string|table, icons_enabled?: boolean, globalstatus?: boolean, component_separators?: string|{left:string, right:string}, section_separators?: string|{left:string, right:string}, disabled_filetypes?: table, always_divide_middle?: boolean, refresh?: {statusline?: integer, tabline?: integer, winbar?: integer}}
  ---@field sections? LualineSectionTable
  ---@field inactive_sections? LualineSectionTable
  ---@field tabline? LualineSectionTable
  ---@field winbar? LualineSectionTable
  ---@field inactive_winbar? LualineSectionTable
  ---@field extensions? (string|table)[]

  ---@type LualineConfig
  opts = {
    options = {
      theme = 'auto',
      globalstatus = true, -- single statusline (laststatus=3)
      disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'snacks_dashboard' } },
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        'branch',
        { 'diff', source = diff_source },
        { 'diagnostics', sources = { 'nvim_diagnostic' } },
      },
      lualine_c = {
        { 'filename', colored = true, icon_only = true, icon = { align = 'right' } },
        { 'aerial' },
      },
      lualine_x = {
        { 'searchcount' },
        { 'overseer' },
        { 'lsp_status' },
        { 'filetype' },
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    extensions = {
      'neo-tree',
      'toggleterm',
      'quickfix',
      'man',
      'aerial',
      'nvim-dap-ui',
      'overseer',
      'lazy',
      'mason',
    },
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
