-- neotest: test-runner UI (summary tree, inline output, watch, DAP strategy).
-- The Rust adapter ships with rustaceanvim (require('rustaceanvim.neotest'));
-- do NOT add neotest-rust alongside it. Registering the adapter also makes
-- rustaceanvim route `:RustLsp testables` through neotest automatically.

return {
  ---@type LazySpec
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'mrcjkb/rustaceanvim', -- provides the rust adapter module
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('rustaceanvim.neotest'),
      },
    })
  end,
  keys = {
    {
      '<Leader>Tt',
      function()
        require('neotest').run.run()
      end,
      desc = 'Test nearest',
    },
    {
      '<Leader>Tf',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      desc = 'Test file',
    },
    {
      '<Leader>Ta',
      function()
        require('neotest').run.run(vim.uv.cwd())
      end,
      desc = 'Test all (cwd)',
    },
    {
      '<Leader>Td',
      function()
        require('neotest').run.run({ strategy = 'dap' })
      end,
      desc = 'Debug nearest test',
    },
    {
      '<Leader>Ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Test summary',
    },
    {
      '<Leader>To',
      function()
        require('neotest').output.open({ enter = true, auto_close = true })
      end,
      desc = 'Test output',
    },
    {
      '<Leader>TO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Test output panel',
    },
    {
      '<Leader>Tx',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Stop test',
    },
    {
      '<Leader>Tw',
      function()
        require('neotest').watch.toggle(vim.fn.expand('%'))
      end,
      desc = 'Watch file tests',
    },
  },
}
