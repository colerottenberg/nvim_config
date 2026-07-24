-- Treesitter (nvim-treesitter `main` branch).
--
-- On the main branch the plugin only installs parsers; highlighting/indentation
-- are Neovim built-ins started per buffer. We install a base set up front and
-- auto-install any detected language on first open, then start highlight+indent.

-- Base parsers to keep installed (merged from the old language packs).
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
}

local MAX_FILESIZE = 1024 * 256

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = vim.fn.argc(-1) == 0, -- load early when a file is opened from the CLI
    event = 'VeryLazy',
    cmd = { 'TSInstall', 'TSUninstall', 'TSUpdate', 'TSLog' },
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
      'windwp/nvim-ts-autotag',
    },
    config = function()
      local ts = require('nvim-treesitter')
      ts.setup({})

      local installed = ts.get_installed()
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure)
      if #missing > 0 then
        ts.install(missing)
      end

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

      -- ── Textobjects ────────────────────────────────────────────────────
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

        -- Function Calls
        ['ad'] = '@call.outer',
        ['id'] = '@call.inner',

        -- Comments
        ['am'] = '@comment.outer',
        ['im'] = '@comment.inner',

        -- Assignments (Left and right hand sides)
        ['as'] = '@assignment.outer',
        ['is'] = '@assignment.inner',
        ['lh'] = '@assignment.lhs',
        ['rh'] = '@assignment.rhs',

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

      -- ── Auto-close/rename HTML-like tags ───────────────────────────────
      require('nvim-ts-autotag').setup({})
    end,
  },
}
