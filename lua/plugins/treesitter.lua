-- Treesitter (nvim-treesitter `main` branch).
--
-- On `main` the plugin only manages parsers; highlighting, indentation, and
-- folding are Neovim built-ins started per buffer. We install a base set of
-- parsers up front and auto-install whatever language is detected on first
-- open, then start highlight + indent + folds for it.

-- Base parsers to keep installed (everything else installs on demand).
local ensure = {
  'bash',
  'c',
  'cpp',
  'cuda',
  'html',
  'java',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'objc',
  'proto',
  'python',
  'query',
  'rust',
  'toml',
  'vim',
  'vimdoc',
  'xml',
}

local MAX_FILESIZE = 1024 * 256

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false, -- load early when a file is opened from the CLI
    cmd = { 'TSInstall', 'TSUninstall', 'TSUpdate', 'TSLog' },
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
      'windwp/nvim-ts-autotag',
    },
    config = function()
      local ts = require('nvim-treesitter')
      ts.setup({})
      ts.install(ensure) -- no-op for parsers already installed

      -- ── Folds ────────────────────────────────────────────────────────
      -- vim.treesitter.foldexpr() returns '0' for buffers without an
      -- attached parser, so this is safe to set globally.
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.o.foldlevelstart = 99 -- open buffers unfolded

      -- ── Highlight + indent ───────────────────────────────────────────
      local function enable(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        local ft = vim.bo[buf].filetype
        if ft == '' then
          return
        end
        local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > MAX_FILESIZE then
          return
        end

        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not vim.tbl_contains(ts.get_available(), lang) then
          return
        end

        local function start()
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end
          if pcall(vim.treesitter.start, buf, lang) then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.tbl_contains(ts.get_installed(), lang) then
          start()
        else
          -- Auto-install the detected language, then start when it finishes.
          ts.install({ lang }):await(vim.schedule_wrap(start))
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
        callback = function(args)
          enable(args.buf)
        end,
      })
      -- Catch buffers whose filetype was set before this config ran.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        enable(buf)
      end

      -- ── Textobjects ──────────────────────────────────────────────────
      require('nvim-treesitter-textobjects').setup({ select = { lookahead = true } })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local function sel(obj)
        return function()
          select.select_textobject(obj, 'textobjects')
        end
      end

      for lhs, obj in pairs({
        -- Functions
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',

        -- Classes
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',

        -- Arguments/Parameters
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',

        -- Conditionals (if/else)
        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',

        -- Loops (for/while)
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',

        -- Blocks/Statements (generic braces/indent blocks)
        ['ab'] = '@block.outer',
        ['ib'] = '@block.inner',

        -- Function calls
        ['ad'] = '@call.outer',
        ['id'] = '@call.inner',

        -- Comments
        ['am'] = '@comment.outer',
        ['im'] = '@comment.inner',

        -- Assignments (left and right hand sides)
        ['as'] = '@assignment.outer',
        ['is'] = '@assignment.inner',
        ['hh'] = '@assignment.lhs',
        ['hl'] = '@assignment.rhs',

        -- Return statements
        ['ar'] = '@return.outer',
        ['ir'] = '@return.inner',
      }) do
        vim.keymap.set({ 'x', 'o' }, lhs, sel(obj), { desc = 'Select ' .. obj })
      end

      vim.keymap.set({ 'n', 'x', 'o' }, ']f', function()
        move.goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[f', function()
        move.goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
        move.goto_next_start('@class.outer', 'textobjects')
      end, { desc = 'Next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
        move.goto_previous_start('@class.outer', 'textobjects')
      end, { desc = 'Previous class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']l', function()
        move.goto_next_start('@loop.outer', 'textobjects')
      end, { desc = 'Next loop start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[l', function()
        move.goto_previous_start('@loop.outer', 'textobjects')
      end, { desc = 'Previous loop start' })

      -- ── Incremental selection ────────────────────────────────────────
      -- `main` dropped the old `configs.incremental_selection` module, so
      -- this re-implements the same idea: grow the visual selection to the
      -- current node's parent, and shrink back through a per-buffer stack
      -- of previously selected nodes.
      local inc_stacks = {} -- buf -> node stack, smallest to largest

      local function select_node(node)
        local sr, sc, er, ec = node:range()
        local last_line, last_col
        if ec == 0 then
          last_line = er -- 0-indexed er-1 line, as a 1-indexed line number
          last_col = math.max(vim.fn.col({ last_line, '$' }) - 1, 1)
        else
          last_line = er + 1
          last_col = ec
        end
        vim.fn.setpos("'<", { 0, sr + 1, sc + 1, 0 })
        vim.fn.setpos("'>", { 0, last_line, last_col, 0 })
        vim.cmd('normal! gv')
      end

      local function init_selection()
        local buf = vim.api.nvim_get_current_buf()
        local node = vim.treesitter.get_node()
        if not node then
          return
        end
        inc_stacks[buf] = { node }
        select_node(node)
      end

      local function node_incremental()
        local buf = vim.api.nvim_get_current_buf()
        local stack = inc_stacks[buf]
        if not stack then
          init_selection()
          return
        end
        local parent = stack[#stack]:parent()
        if not parent then
          return
        end
        table.insert(stack, parent)
        select_node(parent)
      end

      local function node_decremental()
        local buf = vim.api.nvim_get_current_buf()
        local stack = inc_stacks[buf]
        if not stack or #stack <= 1 then
          return
        end
        table.remove(stack)
        select_node(stack[#stack])
      end

      vim.api.nvim_create_autocmd('ModeChanged', {
        pattern = '*:n',
        group = vim.api.nvim_create_augroup('user_treesitter_incremental', { clear = true }),
        callback = function(args)
          inc_stacks[args.buf] = nil
        end,
      })

      vim.keymap.set('n', 'gnn', init_selection, { desc = 'Init incremental selection' })
      vim.keymap.set('x', 'n', node_incremental, { desc = 'Expand incremental selection' })
      vim.keymap.set('x', 'm', node_decremental, { desc = 'Shrink incremental selection' })

      -- ── Auto-close/rename HTML-like tags ─────────────────────────────
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },
}
