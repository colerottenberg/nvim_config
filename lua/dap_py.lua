-- dap_py: Python debugging wired through `uv`-managed project environments.
--
-- This is the module that `lua/plugins/dap.lua` expects via
-- `require("dap_py")`. It registers a Python adapter that launches
-- `debugpy.adapter` inside the project's environment using
--   uv run --with debugpy -- python -m debugpy.adapter
-- so the debuggee sees your project's dependencies AND gets debugpy injected
-- ephemerally — you do NOT need `uv add --dev debugpy`. It exposes a set of
-- named launch/attach configurations plus a `run(name)` helper used by the
-- `<Leader>dt` / `<Leader>dT` keymaps.
--
-- Prereqs in the target project: just `uv sync` (and `pytest` as a dep if you
-- want the pytest configs). debugpy is supplied by `--with` at debug time.
--
-- See the companion guide: docs/dap-guide.md
local M = {}

-- Common fields shared by every launch config (keeps definitions DRY).
local function launch(extra)
  return vim.tbl_extend("error", {
    type = "python",
    request = "launch",
    console = "integratedTerminal", -- gives the debuggee a real TTY via runInTerminal
    cwd = "${workspaceFolder}",
    justMyCode = false,             -- step into library code too; flip to true to stay in your code
  }, extra)
end

local function launch_dir(extra)
  return vim.tbl_extend("error", {
    type = "python",
    request = "launch",
    console = "integratedTerminal", -- gives the debuggee a real TTY via runInTerminal
    justMyCode = false,             -- step into library code too; flip to true to stay in your code
  }, extra)
end
-- Async text prompt via `vim.ui.input` (routed through dressing.nvim's UI,
-- unlike `vim.fn.input`). Returns a coroutine, which is how nvim-dap expects
-- config fields to resolve asynchronously -- see `:h dap-configuration`.
-- `transform` maps the raw answer (never nil) to the field's final value.
local function ui_input(opts, transform)
  transform = transform or function(answer) return answer end
  return coroutine.create(function(dap_run_co)
    vim.ui.input(opts, function(answer) coroutine.resume(dap_run_co, transform(answer or "")) end)
  end)
end

-- Build an args prompt. `completion` is a `vim.ui.input` completion type
-- ("file" by default) so you can <Tab>-complete paths while typing args —
-- handy for finding the script/data files you want to pass to the debuggee.
local function prompt(label, default, completion)
  return function()
    -- split on spaces so the user can type multiple args at the prompt
    return ui_input({ prompt = label, default = default or "", completion = completion or "file" }, function(answer)
      if answer == "" then return {} end
      return vim.split(answer, "%s+", { trimempty = true })
    end)
  end
end

local function prompt_dir(label, default, completion)
  return function()
    -- split on spaces so the user can type multiple args at the prompt
    return ui_input(
      { prompt = label, default = default or "", completion = completion or "file" },
      function(answer) return answer end
    )
  end
end

-- Sentinel marking "prompt for args, seeded from the dir the user just
-- entered" in a `launch_dir_first` config's `args` field (see below).
local ARGS_FROM_DIR = {}

-- Like `launch_dir`, but guarantees the dir prompt happens *before* `args` is
-- resolved, and seeds the args prompt's file-completion from that dir.
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
        vim.ui.input({ prompt = "Dir: ", default = vim.fn.getcwd(), completion = "dir" }, function(answer)
          dir = answer or ""
          coroutine.resume(co)
        end)
      end)
      coroutine.yield()

      local cfg = vim.tbl_extend("error", {
        type = "python",
        request = "launch",
        console = "integratedTerminal", -- gives the debuggee a real TTY via runInTerminal
        justMyCode = false,             -- step into library code too; flip to true to stay in your code
      }, extra)
      cfg.cwd = dir
      if cfg.args == ARGS_FROM_DIR then
        -- seed with `dir .. "/"` so <Tab>-completion browses that dir, not cwd
        cfg.args = prompt("Args: ", dir ~= "" and (dir .. "/") or "")
      end
      return cfg
    end,
  })
end

-- Named configurations. `run(name)` looks them up here; `setup()` also pushes
-- them onto `dap.configurations.python` so they appear in the
-- `:lua require('dap').continue()` picker (your `<Leader>dc`).
M.configs = {
  -- ── Launch ────────────────────────────────────────────────────────────
  ["file: current"] = launch {
    name = "file: current",
    program = "${file}",
  },
  ["file: current + dir"] = launch_dir {
    name = "file: current + dir",
    program = "${file}",
    cwd = prompt_dir "Dir: ",
  },
  ["file: current + args"] = launch {
    name = "file: current + args",
    program = "${file}",
    args = prompt "Args: ",
  },
  ["file: current + args + dir"] = launch_dir_first {
    name = "file: current + args + dir",
    program = "${file}",
    args = ARGS_FROM_DIR,
  },
  ["module: -m ..."] = launch {
    name = "module: -m ...",
    module = function() return ui_input { prompt = "Module (e.g. mypkg.main): " } end,
    args = prompt "Args: ",
  },
  -- Packaged CLI (Typer/Click) installed as a console_script entry point.
  -- Runs the generated wrapper in .venv/bin/<name>, exactly like production.
  ["cli: entry point"] = launch {
    name = "cli: entry point",
    program = function()
      return ui_input({ prompt = "Entry point (console_script name): " }, function(name)
        if vim.fn.has "wsl" == 1 then
          return vim.fn.getcwd() .. "/.venv/bin/" .. name
        elseif vim.fn.has "win32" == 1 then
          return vim.fn.getcwd() .. "/.venv/Scripts/" .. name .. ".exe"
        else
          return vim.fn.getcwd() .. "/.venv/bin/" .. name
        end
      end)
    end,
    args = prompt "CLI args: ",
  },
  ["cli: entry point + dir"] = launch_dir_first {
    name = "cli: entry point + dir",
    program = function()
      return ui_input({ prompt = "Entry point (console_script name): " }, function(name)
        if vim.fn.has "wsl" == 1 then
          return vim.fn.getcwd() .. "/.venv/bin/" .. name
        elseif vim.fn.has "win32" == 1 then
          return vim.fn.getcwd() .. "/.venv/Scripts/" .. name .. ".exe"
        else
          return vim.fn.getcwd() .. "/.venv/bin/" .. name
        end
      end)
    end,
    args = ARGS_FROM_DIR,
  },

  ["cli: list entry points"] = launch {
    name = "cli: list entry points",

    program = function()
      return coroutine.create(function(coro)
        local dir = vim.fn.has "win32" == 1 and ".venv/Scripts" or ".venv/bin"
        local entries = vim.fn.readdir(dir)

        vim.ui.select(entries, {
          prompt = "Select entry point:",
        }, function(choice) coroutine.resume(coro, vim.fn.getcwd() .. "/" .. dir .. "/" .. choice) end)
      end)
    end,
    args = prompt "CLI args:",
  },

  ["cli: list entry points + dir"] = launch_dir_first {
    name = "cli: list entry points + dir",

    program = function()
      return coroutine.create(function(coro)
        local dir = vim.fn.has "win32" == 1 and ".venv/Scripts" or ".venv/bin"
        local entries = vim.fn.readdir(dir)

        vim.ui.select(entries, {
          prompt = "Select entry point:",
        }, function(choice) coroutine.resume(coro, vim.fn.getcwd() .. "/" .. dir .. "/" .. choice) end)
      end)
    end,
    args = ARGS_FROM_DIR,
  },

  -- ── pytest ────────────────────────────────────────────────────────────
  ["pytest: current file"] = launch {
    name = "pytest: current file",
    module = "pytest",
    args = { "${file}", "-s", "-vv" },
  },
  ["pytest: current file (filter)"] = launch {
    name = "pytest: current file (filter)",
    module = "pytest",
    args = function()
      return ui_input({ prompt = "pytest -k filter: " }, function(k)
        local args = { "${file}", "-s", "-vv" }
        if k ~= "" then
          table.insert(args, "-k")
          table.insert(args, k)
        end
        return args
      end)
    end,
  },
  ["pytest: whole suite"] = launch {
    name = "pytest: whole suite",
    module = "pytest",
    args = { "-s", "-vv" },
  },

  -- ── Attach ────────────────────────────────────────────────────────────
  -- Local listener, e.g. started with:
  --   uv run --with debugpy python -m debugpy --listen 5678 --wait-for-client app.py
  ["attach: localhost:5678"] = {
    type = "python",
    request = "attach",
    name = "attach: localhost:5678",
    connect = { host = "127.0.0.1", port = 5678 },
    justMyCode = false,
  },
  -- Remote listener (container / another host). Prompts for host:port and maps
  -- the remote source root back to this workspace so breakpoints bind.
  ["attach: remote (host:port)"] = {
    type = "python",
    request = "attach",
    name = "attach: remote (host:port)",
    connect = function()
      return ui_input({ prompt = "debugpy listener (host:port): ", default = "127.0.0.1:5678" }, function(hostport)
        local host, port = hostport:match "^(.-):(%d+)$"
        return { host = host or "127.0.0.1", port = tonumber(port) or 5678 }
      end)
    end,
    pathMappings = {
      { localRoot = "${workspaceFolder}", remoteRoot = "." },
    },
    justMyCode = false,
  },
}

-- Order shown in the `<Leader>dc` picker.
local ORDER = {
  "file: current",
  "file: current + dir",
  "file: current + args",
  "file: current + args + dir",
  "module: -m ...",
  "cli: entry point",
  "cli: entry point + dir",
  "cli: list entry points",
  "cli: list entry points + dir",
  "pytest: current file",
  "pytest: current file (filter)",
  "pytest: whole suite",
  "attach: localhost:5678",
  "attach: remote (host:port)",
}

-- The adapter. For `launch`, run `debugpy.adapter` through `uv` so it executes
-- in the project venv with debugpy injected (falling back to a plain
-- interpreter if `uv` is absent). For `attach`, point nvim-dap at the listener.
local function adapter(callback, config)
  if config.request == "attach" then
    local opts = config.connect or config
    callback {
      type = "server",
      host = opts.host or "127.0.0.1",
      port = assert(tonumber(opts.port), "dap_py: attach configuration requires `connect.port`"),
    }
    return
  end

  if vim.fn.executable "uv" == 1 then
    callback {
      type = "executable",
      command = "uv",
      args = { "run", "--with", "debugpy", "--", "python", "-m", "debugpy.adapter" },
    }
  else
    -- Fallback: an active venv, a local .venv, or python3 on PATH.
    local py = (vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. "/bin/python")
        or (vim.fn.executable(vim.fn.getcwd() .. "/.venv/bin/python") == 1 and vim.fn.getcwd() .. "/.venv/bin/python")
        or (vim.fn.exepath "python3" ~= "" and vim.fn.exepath "python3")
        or "python"
    callback { type = "executable", command = py, args = { "-m", "debugpy.adapter" } }
  end
end

-- Guards against re-appending duplicate configurations: setup() is called
-- from after/ftplugin/python.lua, so it runs once per Python buffer opened.
local did_setup = false

function M.setup()
  if did_setup then return end
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("dap_py: nvim-dap is not available", vim.log.levels.WARN)
    return
  end
  did_setup = true

  dap.adapters.python = adapter

  dap.configurations.python = dap.configurations.python or {}
  for _, name in ipairs(ORDER) do
    table.insert(dap.configurations.python, vim.deepcopy(M.configs[name]))
  end
end

-- Launch a named configuration directly (used by the keymaps).
function M.run(name)
  local cfg = M.configs[name]
  if not cfg then
    vim.notify("dap_py: unknown configuration '" .. tostring(name) .. "'", vim.log.levels.ERROR)
    return
  end
  require("dap").run(vim.deepcopy(cfg))
end

return M
