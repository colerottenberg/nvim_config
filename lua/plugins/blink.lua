-- Completion (blink.cmp) with LuaSnip, lazydev, and DAP sources.

local function has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

return {
  'saghen/blink.cmp',
  version = '1.*',
  event = { 'InsertEnter', 'CmdlineEnter' },
  dependencies = {
    'L3MON4D3/LuaSnip',
    'rafamadriz/friendly-snippets',
    'saghen/blink.compat',
    'onsails/lspkind.nvim',
  },
  ---@type blink.cmp.Config
  opts = {

    enabled = function()
      -- 1. Check if we are inside a UI element we want to FORCE allow
      local allowed_fts = { 'dap-repl', 'dapui_watches', 'dapui_hover', 'snacks_input' }
      if vim.tbl_contains(allowed_fts, vim.bo.filetype) then
        return true
      end

      -- 2. Keep the original safety guards for everything else
      if vim.bo.buftype == 'prompt' then
        return false
      end
      return vim.b.completion ~= false
    end,
    snippets = { preset = 'luasnip' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
      per_filetype = {
        ['dap-repl'] = { 'dap', 'buffer' },
        dapui_watches = { 'dap', 'buffer' },
        dapui_hover = { 'dap', 'buffer' },
      },
      providers = {
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
        dap = { name = 'dap', module = 'blink.compat.source' },
      },
    },
    fuzzy = { implementation = 'prefer_rust' },
    appearance = { nerd_font_variant = 'mono' },
    keymap = {
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-N>'] = { 'select_next', 'show' },
      ['<C-P>'] = { 'select_prev', 'show' },
      ['<C-J>'] = { 'select_next', 'fallback' },
      ['<C-K>'] = { 'select_prev', 'fallback' },
      ['<C-U>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-D>'] = { 'scroll_documentation_down', 'fallback' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Tab>'] = {
        'select_next',
        'snippet_forward',
        function(cmp)
          if has_words_before() or vim.api.nvim_get_mode().mode == 'c' then
            return cmp.show()
          end
        end,
        'fallback',
      },
      ['<S-Tab>'] = {
        'select_prev',
        'snippet_backward',
        function(cmp)
          if vim.api.nvim_get_mode().mode == 'c' then
            return cmp.show()
          end
        end,
        'fallback',
      },
    },
    completion = {
      ghost_text = {
        enabled = true,
        show_without_selection = true,
      },
      list = { selection = { preselect = false, auto_insert = true } },
      menu = {
        auto_show = function(ctx)
          return ctx.mode ~= 'cmdline'
        end,
        winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
        draw = {
          treesitter = { 'lsp' },
          components = {
            kind_icon = {
              text = function(ctx)
                return require('lspkind').symbol_map[ctx.kind] or ''
              end,
            },
          },
        },
      },
      accept = { auto_brackets = { enabled = true } },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
        window = { winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None' },
      },
    },
    cmdline = {
      keymap = { ['<End>'] = { 'hide', 'fallback' } },
      completion = { ghost_text = { enabled = true } },
    },
    signature = {
      window = { winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder' },
    },
  },
}
