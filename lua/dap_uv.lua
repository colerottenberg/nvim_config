-- dap_uv: Python debugging wired through `uv`-managed project environments.
--
-- This is the module that `lua/plugins/debugging.lua` expects via
-- `require("dap_uv")`. It registers a Python adapter that launches
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
    justMyCode = false, -- step into library code too; flip to true to stay in your code
  }, extra)
end

-- Build an args prompt. `completion` is a `vim.fn.input` completion type
-- ("file" by default) so you can <Tab>-complete paths while typing args —
-- handy for finding the script/data files you want to pass to the debuggee.
local function prompt(label, default, completion)
  return function()
    -- split on spaces so the user can type multiple args at the prompt
    local answer = vim.fn.input {
      prompt = label,
      default = default or "",
      completion = completion or "file",
    }
    if answer == "" then return {} end
    return vim.split(answer, "%s+", { trimempty = true })
  end
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
  ["file: current + args"] = launch {
    name = "file: current + args",
    program = "${file}",
    args = prompt "Args: ",
  },
  ["module: -m ..."] = launch {
    name = "module: -m ...",
    module = function() return vim.fn.input "Module (e.g. mypkg.main): " end,
    args = prompt "Args: ",
  },
  -- Packaged CLI (Typer/Click) installed as a console_script entry point.
  -- Runs the generated wrapper in .venv/bin/<name>, exactly like production.
  ["cli: entry point"] = launch {
    name = "cli: entry point",
    program = function()
      local name = vim.fn.input "Entry point (console_script name): "
      if vim.fn.has "wsl" == 1 then
        return vim.fn.getcwd() .. "/.venv/bin/" .. name
      elseif vim.fn.has "win32" == 1 then
        return vim.fn.getcwd() .. "/.venv/Scripts/" .. name .. ".exe"
      else
        return vim.fn.getcwd() .. "/.venv/bin/" .. name
      end
    end,
    args = prompt "CLI args: ",
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
      local k = vim.fn.input "pytest -k filter: "
      local args = { "${file}", "-s", "-vv" }
      if k ~= "" then
        table.insert(args, "-k")
        table.insert(args, k)
      end
      return args
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
      local hostport = vim.fn.input("debugpy listener (host:port): ", "127.0.0.1:5678")
      local host, port = hostport:match "^(.-):(%d+)$"
      return { host = host or "127.0.0.1", port = tonumber(port) or 5678 }
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
  "file: current + args",
  "module: -m ...",
  "cli: entry point",
  "cli: list entry points",
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
      port = assert(tonumber(opts.port), "dap_uv: attach configuration requires `connect.port`"),
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

function M.setup()
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("dap_uv: nvim-dap is not available", vim.log.levels.WARN)
    return
  end

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
    vim.notify("dap_uv: unknown configuration '" .. tostring(name) .. "'", vim.log.levels.ERROR)
    return
  end
  require("dap").run(vim.deepcopy(cfg))
end

return M
