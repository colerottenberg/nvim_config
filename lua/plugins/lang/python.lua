-- Python: uv-managed projects. Debugging (nvim-dap + debugpy), pytest, and uv
-- project tasks. All python keymaps live in the `keys` tables below (cpp.lua /
-- rust.lua style; lazy binds them buffer-locally for ft=python). LSP-specific
-- keymaps (ruff code actions) go through Snacks.keymap so they only exist in
-- buffers where that server is attached.
--
-- Debugging launches `debugpy.adapter` inside the project's environment via
--   uv run --with debugpy -- python -m debugpy.adapter
-- so the debuggee sees your project's dependencies AND gets debugpy injected
-- ephemerally -- you do NOT need `uv add --dev debugpy`. Prereqs in the target
-- project: just `uv sync` (and `pytest` as a dep for the pytest keys).
--
-- Run / test / uv tasks run through overseer (output in its task list).

-- ── Overseer tasks ────────────────────────────────────────────────────────

local function task(cmd)
  require('overseer').new_task({ cmd = cmd, components = { 'default' } }):start()
end

-- `uv run <args>` when uv is available, otherwise run <args> directly.
local function uv_run(args)
  if vim.fn.executable('uv') == 1 then
    return vim.list_extend({ 'uv', 'run' }, args)
  end
  return args
end

-- Run a fixed command list (built at keypress time so `%` is the live buffer).
local function run(build)
  return function()
    task(build())
  end
end

-- Prompt for space-separated args, then run `build(args)`. Cancel aborts.
local function run_prompt(prompt, build, completion)
  return function()
    vim.ui.input({ prompt = prompt, completion = completion or 'file' }, function(input)
      if input == nil then
        return
      end
      task(build(vim.split(input, '%s+', { trimempty = true })))
    end)
  end
end

local function current_file()
  return vim.fn.expand('%:p')
end

-- ── DAP ───────────────────────────────────────────────────────────────────

-- Common fields shared by every launch config (keeps definitions DRY).
local function launch(extra)
  return vim.tbl_extend('error', {
    type = 'python',
    request = 'launch',
    console = 'integratedTerminal', -- gives the debuggee a real TTY via runInTerminal
    cwd = '${workspaceFolder}',
    justMyCode = false, -- step into library code too; flip to true to stay in your code
  }, extra)
end

local function launch_dir(extra)
  return vim.tbl_extend('error', {
    type = 'python',
    request = 'launch',
    console = 'integratedTerminal', -- gives the debuggee a real TTY via runInTerminal
    justMyCode = false, -- step into library code too; flip to true to stay in your code
  }, extra)
end

-- Async text prompt via `vim.ui.input` (routed through dressing.nvim's UI,
-- unlike `vim.fn.input`). Returns a coroutine, which is how nvim-dap expects
-- config fields to resolve asynchronously -- see `:h dap-configuration`.
-- `transform` maps the raw answer (never nil) to the field's final value.
local function ui_input(opts, transform)
  transform = transform or function(answer)
    return answer
  end
  return coroutine.create(function(dap_run_co)
    vim.ui.input(opts, function(answer)
      coroutine.resume(dap_run_co, transform(answer or ''))
    end)
  end)
end

-- Build an args prompt. `completion` is a `vim.ui.input` completion type
-- ("file" by default) so you can <Tab>-complete paths while typing args.
local function prompt(label, default, completion)
  return function()
    -- split on spaces so the user can type multiple args at the prompt
    return ui_input({ prompt = label, default = default or '', completion = completion or 'file' }, function(answer)
      if answer == '' then
        return {}
      end
      return vim.split(answer, '%s+', { trimempty = true })
    end)
  end
end

local function prompt_dir(label, default, completion)
  return function()
    return ui_input({ prompt = label, default = default or '', completion = completion or 'file' })
  end
end

-- Sentinel marking "prompt for args, with file-completion rooted at the dir
-- the user just entered" in a `launch_dir_first` config's `args` field.
local ARGS_FROM_DIR = {}

-- Like `launch_dir`, but guarantees the dir prompt happens *before* `args` is
-- resolved, and roots the args prompt's file-completion at that dir.
--
-- Why not just put both as fields on the config table? nvim-dap resolves
-- function/coroutine fields via `for k, v in pairs(config)`, whose order is
-- unspecified -- `args` could get resolved before `cwd` on any given run.
-- Instead we exploit dap's support for a config with a `__call` metamethod
-- (`:h dap-configuration`): dap invokes that once, synchronously, before it
-- resolves any individual field, and it runs inside the same coroutine dap
-- uses for `vim.ui.input`-based prompts, so we can yield/resume here too.
local function launch_dir_first(extra)
  -- `name` must live on the outer table (not just inside `__call`'s result):
  -- dap's config picker (`<Leader>dc`) reads `configuration.name` to build
  -- its label *before* ever invoking `__call`, so a bare `{}` here shows up
  -- as a nil label and crashes the picker's formatter.
  return setmetatable({ name = extra.name }, {
    __call = function()
      local co = assert(coroutine.running(), "launch_dir_first: must run inside dap's coroutine")
      local dir
      vim.schedule(function()
        vim.ui.input({ prompt = 'Dir: ', completion = 'dir' }, function(answer)
          dir = answer or ''
          coroutine.resume(co)
        end)
      end)
      coroutine.yield()

      local cfg = launch_dir(extra)
      cfg.cwd = dir
      if cfg.args == ARGS_FROM_DIR then
        cfg.args = function()
          -- Root <Tab>-completion at `dir` by `:lcd`-ing there just for the
          -- duration of this prompt, so the args field stays empty by
          -- default instead of being pre-filled with `dir`.
          local prev_cwd
          if dir ~= '' then
            prev_cwd = vim.fn.getcwd()
            vim.cmd.lcd(dir)
          end
          return ui_input({ prompt = 'Args: ', completion = 'file' }, function(answer)
            if prev_cwd then
              vim.cmd.lcd(prev_cwd)
            end
            if answer == '' then
              return {}
            end
            return vim.split(answer, '%s+', { trimempty = true })
          end)
        end
      end
      return cfg
    end,
  })
end

-- Path to a console_script in the project venv (or PATH as a fallback).
local function entry_point_path(name)
  if vim.fn.has('win32') == 1 then
    local venv_path = vim.fn.getcwd() .. '/.venv/Scripts/' .. name .. '.exe'
    return vim.uv.fs_stat(venv_path) and venv_path or vim.fn.exepath(name .. '.exe')
  end
  local venv_path = vim.fn.getcwd() .. '/.venv/bin/' .. name
  return vim.uv.fs_stat(venv_path) and venv_path or vim.fn.exepath(name)
end

local function ask_entry_point()
  return ui_input({ prompt = 'Entry point (console_script name): ' }, entry_point_path)
end

local function pick_entry_point()
  return coroutine.create(function(coro)
    local dir = vim.fn.has('win32') == 1 and '.venv/Scripts' or '.venv/bin'
    local entries = vim.fn.readdir(dir)
    vim.ui.select(entries, { prompt = 'Select entry point:' }, function(choice)
      coroutine.resume(coro, choice and (vim.fn.getcwd() .. '/' .. dir .. '/' .. choice) or require('dap').ABORT)
    end)
  end)
end

-- Named configurations. `dap_run(name)` looks them up here; `dap_setup()` also
-- pushes them onto `dap.configurations.python` so they appear in the
-- `<Leader>dc` picker.
local configs = {
  -- ── Launch ──────────────────────────────────────────────────────────────
  ['file: current'] = launch({
    name = 'file: current',
    program = '${file}',
  }),
  ['file: current + dir'] = launch_dir({
    name = 'file: current + dir',
    program = '${file}',
    cwd = prompt_dir('Dir: '),
  }),
  ['file: current + args'] = launch({
    name = 'file: current + args',
    program = '${file}',
    args = prompt('Args: '),
  }),
  ['file: current + args + dir'] = launch_dir_first({
    name = 'file: current + args + dir',
    program = '${file}',
    args = ARGS_FROM_DIR,
  }),
  ['module: -m ...'] = launch({
    name = 'module: -m ...',
    module = function()
      return ui_input({ prompt = 'Module (e.g. mypkg.main): ' })
    end,
    args = prompt('Args: '),
  }),
  -- Packaged CLI (Typer/Click) installed as a console_script entry point.
  -- Runs the generated wrapper in .venv/bin/<name>, exactly like production.
  ['cli: entry point'] = launch({
    name = 'cli: entry point',
    program = ask_entry_point,
    args = prompt('CLI args: '),
  }),
  ['cli: entry point + dir'] = launch_dir_first({
    name = 'cli: entry point + dir',
    program = ask_entry_point,
    args = ARGS_FROM_DIR,
  }),
  ['cli: list entry points'] = launch({
    name = 'cli: list entry points',
    program = pick_entry_point,
    args = prompt('CLI args: '),
  }),
  ['cli: list entry points + dir'] = launch_dir_first({
    name = 'cli: list entry points + dir',
    program = pick_entry_point,
    args = ARGS_FROM_DIR,
  }),

  -- ── pytest ──────────────────────────────────────────────────────────────
  ['pytest: current file'] = launch({
    name = 'pytest: current file',
    module = 'pytest',
    args = { '${file}', '-s', '-vv' },
  }),
  ['pytest: current file (filter)'] = launch({
    name = 'pytest: current file (filter)',
    module = 'pytest',
    args = function()
      return ui_input({ prompt = 'pytest -k filter: ' }, function(k)
        local args = { '${file}', '-s', '-vv' }
        if k ~= '' then
          vim.list_extend(args, { '-k', k })
        end
        return args
      end)
    end,
  }),
  ['pytest: whole suite'] = launch({
    name = 'pytest: whole suite',
    module = 'pytest',
    args = { '-s', '-vv' },
  }),

  -- ── Attach ──────────────────────────────────────────────────────────────
  -- Local listener, e.g. started with:
  --   uv run --with debugpy python -m debugpy --listen 5678 --wait-for-client app.py
  ['attach: localhost:5678'] = {
    type = 'python',
    request = 'attach',
    name = 'attach: localhost:5678',
    connect = { host = '127.0.0.1', port = 5678 },
    justMyCode = false,
  },
  -- Remote listener (container / another host). Prompts for host:port and maps
  -- the remote source root back to this workspace so breakpoints bind.
  ['attach: remote (host:port)'] = {
    type = 'python',
    request = 'attach',
    name = 'attach: remote (host:port)',
    connect = function()
      return ui_input({ prompt = 'debugpy listener (host:port): ', default = '127.0.0.1:5678' }, function(hostport)
        local host, port = hostport:match('^(.-):(%d+)$')
        return { host = host or '127.0.0.1', port = tonumber(port) or 5678 }
      end)
    end,
    pathMappings = {
      { localRoot = '${workspaceFolder}', remoteRoot = '.' },
    },
    justMyCode = false,
  },
}

-- Order shown in the `<Leader>dc` and `<LocalLeader>D` pickers.
local ORDER = {
  'file: current',
  'file: current + dir',
  'file: current + args',
  'file: current + args + dir',
  'module: -m ...',
  'cli: entry point',
  'cli: entry point + dir',
  'cli: list entry points',
  'cli: list entry points + dir',
  'pytest: current file',
  'pytest: current file (filter)',
  'pytest: whole suite',
  'attach: localhost:5678',
  'attach: remote (host:port)',
}

-- The adapter. For `launch`, run `debugpy.adapter` through `uv` so it executes
-- in the project venv with debugpy injected (falling back to a plain
-- interpreter if `uv` is absent). For `attach`, point nvim-dap at the listener.
local function adapter(callback, config)
  if config.request == 'attach' then
    local opts = config.connect or config
    callback({
      type = 'server',
      host = opts.host or '127.0.0.1',
      port = assert(tonumber(opts.port), 'python dap: attach configuration requires `connect.port`'),
    })
    return
  end

  if vim.fn.executable('uv') == 1 then
    callback({
      type = 'executable',
      command = 'uv',
      args = { 'run', '--with', 'debugpy', '--', 'python', '-m', 'debugpy.adapter' },
    })
  else
    -- Fallback: an active venv, a local .venv, or python3 on PATH.
    local py = (vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. '/bin/python')
      or (vim.fn.executable(vim.fn.getcwd() .. '/.venv/bin/python') == 1 and vim.fn.getcwd() .. '/.venv/bin/python')
      or (vim.fn.exepath('python3') ~= '' and vim.fn.exepath('python3'))
      or 'python'
    callback({ type = 'executable', command = py, args = { '-m', 'debugpy.adapter' } })
  end
end

-- Registers the adapter + configs once. Runs when nvim-dap is configured (see
-- the DapConfigured hook in the nvim-dap spec's `init`) and defensively before
-- every python debug keymap.
local did_setup = false
local function dap_setup()
  if did_setup then
    return
  end
  did_setup = true
  local dap = require('dap')
  dap.adapters.python = adapter
  dap.configurations.python = dap.configurations.python or {}
  for _, name in ipairs(ORDER) do
    table.insert(dap.configurations.python, vim.deepcopy(configs[name]))
  end
end

-- Launch a named configuration directly.
local function dap_run(name)
  return function()
    dap_setup()
    require('dap').run(vim.deepcopy(configs[name]))
  end
end

local function dap_pick()
  dap_setup()
  vim.ui.select(ORDER, { prompt = 'Python debug config:' }, function(choice)
    if choice then
      require('dap').run(vim.deepcopy(configs[choice]))
    end
  end)
end

-- ── neotest ───────────────────────────────────────────────────────────────

local function neotest(fn)
  return function()
    fn(require('neotest'))
  end
end

-- ── LSP (ruff) ────────────────────────────────────────────────────────────

local function code_action(kind)
  return function()
    vim.lsp.buf.code_action({ apply = true, context = { only = { kind }, diagnostics = {} } })
  end
end

return {
  ---@type LazySpec
  {
    'mfussenegger/nvim-dap',
    init = function()
      -- Register the python adapter/configs as soon as nvim-dap is configured
      -- (from any keymap), so they show in `<Leader>dc` without a python
      -- keypress. `DapConfigured` is fired at the end of plugins/dap.lua's config.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'DapConfigured',
        group = vim.api.nvim_create_augroup('python_dap_setup', { clear = true }),
        once = true,
        callback = dap_setup,
      })

      -- Ruff code actions, only in buffers where ruff is attached.
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        once = true,
        callback = function()
          Snacks.keymap.set('n', '<LocalLeader>o', code_action('source.organizeImports.ruff'), {
            lsp = { name = 'ruff' },
            desc = 'Ruff: organize imports',
          })
          Snacks.keymap.set('n', '<LocalLeader>F', code_action('source.fixAll.ruff'), {
            lsp = { name = 'ruff' },
            desc = 'Ruff: fix all',
          })
        end,
      })
    end,
    keys = {
      -- Debug
      { '<LocalLeader>d', dap_run('file: current'), desc = 'Python: debug file', ft = 'python' },
      { '<LocalLeader>A', dap_run('file: current + args'), desc = 'Python: debug file with args', ft = 'python' },
      { '<LocalLeader>D', dap_pick, desc = 'Python: pick debug config', ft = 'python' },
      { '<LocalLeader>c', dap_run('cli: entry point'), desc = 'Python: debug CLI entry point', ft = 'python' },
      { '<LocalLeader>C', dap_run('cli: list entry points'), desc = 'Python: debug CLI (pick)', ft = 'python' },

      -- Debug pytest
      { '<LocalLeader>tF', dap_run('pytest: current file'), desc = 'Pytest: debug file', ft = 'python' },
      {
        '<LocalLeader>tK',
        dap_run('pytest: current file (filter)'),
        desc = 'Pytest: debug file (-k filter)',
        ft = 'python',
      },
      { '<LocalLeader>tA', dap_run('pytest: whole suite'), desc = 'Pytest: debug suite', ft = 'python' },
    },
  },

  ---@type LazySpec
  {
    'stevearc/overseer.nvim',
    keys = {
      -- Run
      {
        '<LocalLeader>r',
        run(function()
          return uv_run({ 'python', current_file() })
        end),
        desc = 'Python: run file',
        ft = 'python',
      },
      {
        '<LocalLeader>a',
        run_prompt('Args: ', function(args)
          return uv_run(vim.list_extend({ 'python', current_file() }, args))
        end),
        desc = 'Python: run file with args',
        ft = 'python',
      },
      {
        '<LocalLeader>m',
        run_prompt('Module (and args): ', function(args)
          return uv_run(vim.list_extend({ 'python', '-m' }, args))
        end),
        desc = 'Python: run module (-m)',
        ft = 'python',
      },

      -- pytest
      {
        '<LocalLeader>tf',
        run(function()
          return uv_run({ 'pytest', current_file() })
        end),
        desc = 'Pytest: file',
        ft = 'python',
      },
      {
        '<LocalLeader>tk',
        function()
          vim.ui.input({ prompt = 'pytest -k filter: ' }, function(k)
            if k == nil then
              return
            end
            local cmd = { 'pytest', current_file() }
            if k ~= '' then
              vim.list_extend(cmd, { '-k', k })
            end
            task(uv_run(cmd))
          end)
        end,
        desc = 'Pytest: file (-k filter)',
        ft = 'python',
      },
      {
        '<LocalLeader>ta',
        run(function()
          return uv_run({ 'pytest' })
        end),
        desc = 'Pytest: suite',
        ft = 'python',
      },
      {
        '<LocalLeader>tl',
        run(function()
          return uv_run({ 'pytest', '--lf' })
        end),
        desc = 'Pytest: re-run last failed',
        ft = 'python',
      },

      -- uv project tasks
      {
        '<LocalLeader>us',
        run(function()
          return { 'uv', 'sync' }
        end),
        desc = 'uv sync',
        ft = 'python',
      },
      {
        '<LocalLeader>ul',
        run(function()
          return { 'uv', 'lock' }
        end),
        desc = 'uv lock',
        ft = 'python',
      },
      {
        '<LocalLeader>ut',
        run(function()
          return { 'uv', 'tree' }
        end),
        desc = 'uv tree',
        ft = 'python',
      },
      {
        '<LocalLeader>ua',
        run_prompt('uv add: ', function(args)
          return vim.list_extend({ 'uv', 'add' }, args)
        end, ''),
        desc = 'uv add',
        ft = 'python',
      },
      {
        '<LocalLeader>ur',
        run_prompt('uv remove: ', function(args)
          return vim.list_extend({ 'uv', 'remove' }, args)
        end, ''),
        desc = 'uv remove',
        ft = 'python',
      },
    },
  },

  ---@type LazySpec
  {
    'nvim-neotest/neotest',
    keys = {
      {
        '<LocalLeader>tt',
        neotest(function(nt)
          nt.run.run()
        end),
        desc = 'Neotest: nearest',
        ft = 'python',
      },
      {
        '<LocalLeader>td',
        neotest(function(nt)
          nt.run.run({ strategy = 'dap' })
        end),
        desc = 'Neotest: debug nearest',
        ft = 'python',
      },
      {
        '<LocalLeader>ts',
        neotest(function(nt)
          nt.summary.toggle({ enter = true })
        end),
        desc = 'Neotest: summary',
        ft = 'python',
      },
      {
        '<LocalLeader>to',
        neotest(function(nt)
          nt.output.open({ enter = true, auto_close = true })
        end),
        desc = 'Neotest: output',
        ft = 'python',
      },
      {
        '<LocalLeader>tw',
        neotest(function(nt)
          nt.watch.toggle(vim.fn.expand('%'))
        end),
        desc = 'Neotest: watch file',
        ft = 'python',
      },
    },
  },
}
