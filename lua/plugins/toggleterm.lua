-- Terminal management

-- Cached tool terminals so each toggles the same instance.
local terms = {}
local function toggle_cmd(key, opts)
  return function()
    local Terminal = require('toggleterm.terminal').Terminal
    if not terms[key] then
      terms[key] = Terminal:new(vim.tbl_extend('force', { hidden = true }, opts))
    end
    terms[key]:toggle()
  end
end

local keys = {
  {
    '<F7>',
    '<Cmd>ToggleTerm<CR>',
    mode = { 'n', 't', 'i' },
    desc = 'Toggle terminal',
  },
  {
    "<C-'>",
    '<Cmd>ToggleTerm<CR>',
    mode = { 'n', 't', 'i' },
    desc = 'Toggle terminal',
  },
  { '<Leader>tf', '<Cmd>ToggleTerm direction=float<CR>', desc = 'Float terminal' },
  { '<Leader>th', '<Cmd>ToggleTerm direction=horizontal<CR>', desc = 'Horizontal terminal' },
  { '<Leader>tv', '<Cmd>ToggleTerm direction=vertical<CR>', desc = 'Vertical terminal' },
  { '<Leader>ts', '<Cmd>TermSelect<CR>', desc = 'Select terminal' },
  {
    '<Leader>tb',
    function()
      require('toggleterm').toggle(nil, nil, nil, 'tab')
    end,
    desc = 'Tab terminal',
  },
}

if vim.fn.executable('lazygit') == 1 and vim.fn.executable('git') == 1 then
  local lazygit = toggle_cmd('lazygit', { cmd = 'lazygit', direction = 'float' })
  table.insert(keys, { '<Leader>tl', lazygit, desc = 'ToggleTerm lazygit' })
  table.insert(keys, { '<Leader>gg', lazygit, desc = 'ToggleTerm lazygit' })
end
if vim.fn.executable('node') == 1 then
  table.insert(
    keys,
    { '<Leader>tn', toggle_cmd('node', { cmd = 'node', direction = 'float' }), desc = 'ToggleTerm node' }
  )
end
if vim.fn.executable('ptpython') == 1 or vim.fn.executable('python') == 1 or vim.fn.executable('python3') == 1 then
  local py = vim.fn.executable('ptpython') == 1 and 'ptpython'
    or (vim.fn.executable('python') == 1 and 'python' or 'python3')
  table.insert(
    keys,
    { '<Leader>tp', toggle_cmd('python', { cmd = py, direction = 'float' }), desc = 'ToggleTerm python' }
  )
end

return {
  'akinsho/toggleterm.nvim',
  cmd = { 'ToggleTerm', 'TermExec' },
  keys = keys,

  config = function()
    local tt = require('toggleterm')
    ---@type ToggleTermConfig
    local opts = {
      direction = 'float',
      size = function(term)
        if term.direction == 'horizontal' then
          return vim.o.lines * 0.3
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        else
          size = 20
        end
      end,
      shading_factor = 2,
      on_create = function(t)
        vim.opt_local.foldcolumn = '0'
        vim.opt_local.signcolumn = 'no'
        if t.hidden then
          local function toggle()
            t:toggle()
          end
          vim.keymap.set({ 'n', 't', 'i' }, "<C-'>", toggle, { desc = 'Toggle terminal', buffer = t.bufnr })
          vim.keymap.set({ 'n', 't', 'i' }, '<F7>', toggle, { desc = 'Toggle terminal', buffer = t.bufnr })
        end
      end,
      insert_mappings = true,
      terminal_mappings = true,
      start_in_insert = true,
    }
    tt.setup(opts)
  end,
}
