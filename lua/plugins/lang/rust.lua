-- Rust: rustaceanvim (owns rust_analyzer; loads on ft=rust) + crates.nvim.
-- All rust keymaps live in this file's `keys` table below (cpp.lua style;
-- lazy binds them buffer-locally for ft=rust). Cargo.toml keymaps are set by
-- an autocmd in the crates.nvim spec, gated by filename because Cargo.toml is
-- ft=toml and `ft`-gated keys would leak into every toml buffer.
--
-- rustaceanvim does not support rust-analyzer's Run/Debug CodeLens, so the
-- built-in `grx` (vim.lsp.codelens.run) crashes for Rust. Those lenses are
-- disabled in the server settings below and the working `:RustLsp` commands
-- are mapped instead. `:RustLsp` is buffer-local and only exists after
-- rust-analyzer attaches; these bodies run lazily on keypress.

-- Run a :RustLsp subcommand (string or table, e.g. { 'run', bang = true }).
local function rustlsp(cmd)
  return function()
    vim.cmd.RustLsp(cmd)
  end
end

-- Prompt for extra executable args, then run the given :RustLsp subcommand.
-- Args must be passed as a list so each token becomes a separate argument;
-- a single "subcmd args" string is read by :RustLsp as one (unknown) subcommand.
local function with_args(subcmd)
  return function()
    vim.ui.input({ prompt = subcmd .. ' args: ' }, function(input)
      if input == nil then
        return
      end -- cancelled
      local cmd = vim.split(input, '%s+', { trimempty = true })
      table.insert(cmd, 1, subcmd)
      vim.cmd.RustLsp(cmd)
    end)
  end
end

-- Run a cargo task from overseer's built-in cargo template.
-- Task names are 'cargo <args>' (see :OverseerRun inside a cargo project).
local function cargo(name)
  return function()
    require('overseer').run_task({ name = name })
  end
end

return {
  ---@type LazySpec
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    ft = 'rust',
    init = function()
      -- rustaceanvim reads this global; must exist before the rust ftplugin runs.
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              files = { exclude = { '.direnv', '.git', 'target' } },
              check = { command = 'clippy', extraArgs = { '--no-deps' } },
              cargo = { features = 'all' },
              -- Only visible via the inlay-hint toggle in config/lsp.lua.
              inlayHints = {
                lifetimeElisionHints = { enable = 'skip_trivial' },
                closureReturnTypeHints = { enable = 'with_block' },
              },
              -- Run/Debug lenses would surface the broken `grx` path (see header).
              lens = {
                run = { enable = false },
                debug = { enable = false },
              },
            },
          },
        },
        dap = { load_rust_types = true },
        tools = {
          enable_clippy = false,
          executor = 'toggleterm', -- runnables/debuggables output in toggleterm
        },
      }
    end,
    keys = {
      -- Run / debug / test
      { '<LocalLeader>R', rustlsp('runnables'), desc = 'Rust: pick a runnable', ft = 'rust' },
      { '<LocalLeader>D', rustlsp('debuggables'), desc = 'Rust: pick a debuggable', ft = 'rust' },
      { '<LocalLeader>t', rustlsp('testables'), desc = 'Rust: pick a testable', ft = 'rust' },
      { '<LocalLeader>l', rustlsp({ 'run', bang = true }), desc = 'Rust: re-run last target', ft = 'rust' },
      { '<LocalLeader>j', rustlsp({ 'debug', bang = true }), desc = 'Rust: re-debug last target', ft = 'rust' },
      { '<LocalLeader>a', with_args('run'), desc = 'Rust: run with args', ft = 'rust' },
      { '<LocalLeader>A', with_args('debug'), desc = 'Rust: debug with args', ft = 'rust' },

      -- Diagnostics / docs / navigation
      { '<LocalLeader>k', rustlsp({ 'hover', 'actions' }), desc = 'Rust: hover actions', ft = 'rust' },
      { '<LocalLeader>e', rustlsp('explainError'), desc = 'Rust: explain next error', ft = 'rust' },
      { '<LocalLeader>x', rustlsp('renderDiagnostic'), desc = 'Rust: render next diagnostic', ft = 'rust' },
      { '<LocalLeader>X', rustlsp('relatedDiagnostics'), desc = 'Rust: related diagnostics', ft = 'rust' },
      { '<LocalLeader>o', rustlsp('openDocs'), desc = 'Rust: open docs.rs', ft = 'rust' },
      { '<LocalLeader>p', rustlsp('parentModule'), desc = 'Rust: parent module', ft = 'rust' },
      { '<LocalLeader>f', rustlsp('flyCheck'), desc = 'Rust: fly check (clippy)', ft = 'rust' },

      -- Refactoring. Visual variants go through the cmdline so :RustLsp
      -- receives the '<,'> range (its dispatcher picks the visual impl).
      { '<LocalLeader>m', rustlsp('expandMacro'), desc = 'Rust: expand macro', ft = 'rust' },
      { '<LocalLeader>J', rustlsp('joinLines'), desc = 'Rust: join lines', ft = 'rust' },
      { '<LocalLeader>J', ':RustLsp joinLines<CR>', mode = 'x', silent = true, desc = 'Rust: join lines', ft = 'rust' },
      { '<LocalLeader>s', rustlsp('ssr'), desc = 'Rust: structural replace', ft = 'rust' },
      {
        '<LocalLeader>s',
        ':RustLsp ssr<CR>',
        mode = 'x',
        silent = true,
        desc = 'Rust: structural replace',
        ft = 'rust',
      },

      -- Views (parallels clangd's AST viewer)
      { '<LocalLeader>vh', rustlsp({ 'view', 'hir' }), desc = 'Rust: view HIR', ft = 'rust' },
      { '<LocalLeader>vm', rustlsp({ 'view', 'mir' }), desc = 'Rust: view MIR', ft = 'rust' },
      { '<LocalLeader>vs', rustlsp('syntaxTree'), desc = 'Rust: syntax tree', ft = 'rust' },

      -- Cargo tasks (overseer built-in cargo template)
      { '<LocalLeader>cb', cargo('cargo build'), desc = 'Cargo build', ft = 'rust' },
      { '<LocalLeader>cc', cargo('cargo check'), desc = 'Cargo check', ft = 'rust' },
      { '<LocalLeader>cC', cargo('cargo clean'), desc = 'Cargo clean', ft = 'rust' },
      { '<LocalLeader>cd', cargo('cargo doc --open'), desc = 'Cargo doc (open)', ft = 'rust' },
      { '<LocalLeader>cu', cargo('cargo update'), desc = 'Cargo update', ft = 'rust' },
      { '<LocalLeader>co', rustlsp('openCargo'), desc = 'Rust: open Cargo.toml', ft = 'rust' },
    },
  },

  ---@type LazySpec
  {
    'Saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
    config = function(_, opts)
      local crates = require('crates')
      crates.setup(opts)
      -- lazy.nvim re-fires BufRead after loading, so this also catches the
      -- Cargo.toml buffer that triggered the load.
      vim.api.nvim_create_autocmd('BufRead', {
        group = vim.api.nvim_create_augroup('crates_keymaps', { clear = true }),
        pattern = 'Cargo.toml',
        callback = function(ev)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end
          map('n', '<LocalLeader>v', crates.show_versions_popup, 'Crates: versions popup')
          map('n', '<LocalLeader>f', crates.show_features_popup, 'Crates: features popup')
          map('n', '<LocalLeader>d', crates.show_dependencies_popup, 'Crates: dependencies popup')
          map('n', '<LocalLeader>u', crates.update_crate, 'Crates: update crate')
          map('x', '<LocalLeader>u', crates.update_crates, 'Crates: update selected')
          map('n', '<LocalLeader>U', crates.upgrade_crate, 'Crates: upgrade crate')
          map('x', '<LocalLeader>U', crates.upgrade_crates, 'Crates: upgrade selected')
          map('n', '<LocalLeader>a', crates.update_all_crates, 'Crates: update all')
          map('n', '<LocalLeader>A', crates.upgrade_all_crates, 'Crates: upgrade all')
          map('n', '<LocalLeader>T', crates.toggle, 'Crates: toggle virtual text')
          map('n', '<LocalLeader>oc', crates.open_crates_io, 'Crates: open crates.io')
          map('n', '<LocalLeader>od', crates.open_documentation, 'Crates: open docs.rs')
          map('n', '<LocalLeader>or', crates.open_repository, 'Crates: open repository')
          map('n', '<LocalLeader>oh', crates.open_homepage, 'Crates: open homepage')
        end,
      })
    end,
  },
}
