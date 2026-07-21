# Adding a debug adapter

How to wire up a new debugger in this config. For what a debug adapter
actually *is* (the protocol, wire format, session lifecycle), see
[`dap-protocol.md`](dap-protocol.md). For the debuggers already configured
(Python, C/C++, embedded, ESP32), see [`dap-guide.md`](dap-guide.md).

---

## 1. The mental model

Every debugger needs exactly two things registered with `nvim-dap`:

```lua
-- (a) An ADAPTER: how nvim-dap launches/reaches the debug adapter process.
dap.adapters.<name> = { type = "executable" | "server", ... } -- or a function

-- (b) One or more CONFIGURATIONS per filetype: what to debug.
dap.configurations.<filetype> = { { type = "<name>", request = "launch"|"attach", ... } }
```

`type` in a configuration must match an adapter key. Any field in a
configuration may be a **function** (or a coroutine) — nvim-dap calls it when
you start the session and uses the return value. That's how this repo prompts
for an executable path, a PID, or a remote target.

Two request kinds: **`launch`** (the adapter starts the program) and
**`attach`** (something's already running — a process, a `gdbserver`, an
OpenOCD session — and the adapter connects to it).

Async prompts always go through `vim.ui.input`/`vim.ui.select` wrapped in a
coroutine, never `vim.fn.input` — see the `ui_input` helper duplicated in
`lua/plugins/dap.lua` and `lua/dap_py.lua`, and `:h dap-configuration` for why
a coroutine is what nvim-dap expects for async field resolution.

## 2. Pick where the adapter lives — three existing patterns

**A. Inline in `lua/plugins/dap.lua`'s `config` function** — the C/C++
pattern. Use this when the language doesn't need buffer-scoped lazy loading
or a long list of named configurations. Add your `dap.adapters.<name>` and
`dap.configurations.<ft>` entries directly there, following the existing
`-- ── Adapters ──` / `-- ── Configurations ──` section banners.

**B. A dedicated module, loaded from `after/ftplugin/<ft>.lua`** — the
`lua/dap_py.lua` pattern. Use this when:
- there's a rich set of named configurations you want in a picker (`M.configs`
  + an `ORDER` list, as in `dap_py.lua`),
- the adapter needs nontrivial setup logic (e.g. resolving `uv`/venv/python
  fallback chains),
- or you want buffer-local keymaps that only exist for that filetype (wired
  in the `after/ftplugin/<ft>.lua` file itself, via a local `map()` helper).

The module exposes `setup()` (registers the adapter + pushes configurations
onto `dap.configurations.<ft>`, called once per buffer of that filetype) and
optionally `run(name)` (launches one named config directly, for keymaps).
`setup()` should guard against double-registration (`dap_py.lua` uses a
`did_setup` local) since ftplugins re-run per matching buffer.

**C. Let a language plugin own DAP entirely** — the Rust pattern. If the
language's LSP/tooling plugin already speaks DAP (like `rustaceanvim`'s
`vim.g.rustaceanvim.dap`), don't hand-roll `nvim-dap` adapters/configurations
at all — configure the plugin's own DAP integration instead. Check whether
your language's main plugin already does this before reaching for A or B.

## 3. Installing the adapter binary

`mason-nvim-dap.setup{ ensure_installed = {...} }` in `lua/plugins/dap.lua`
auto-installs adapter binaries via Mason. Add your adapter's Mason package
name there (it currently ensures `"codelldb"` and `"debugpy"`, matching the
adapters actually configured). Anything not in that list must be installed
manually via `:Mason` (or already be on `PATH`, as with GDB or Rust's
`rustaceanvim`-managed `codelldb`).

## 4. Worked example: Go via `delve` (not implemented — a template)

This walks through adding Go end-to-end using pattern **A** (inline), since
Go doesn't need a rich named-config list to start.

1. Install the adapter: add `"delve"` to `ensure_installed` in
   `lua/plugins/dap.lua`.
2. Define the adapter, alongside the existing `-- ── Adapters ──` block:
   ```lua
   dap.adapters.delve = {
     type = "server",
     port = "${port}",
     executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } },
   }
   ```
3. Define configurations, alongside `dap.configurations.cpp`/`.c`:
   ```lua
   dap.configurations.go = {
     {
       type = "delve",
       name = "debug: current package",
       request = "launch",
       program = "${fileDirname}",
     },
     {
       type = "delve",
       name = "debug: current file",
       request = "launch",
       program = "${file}",
     },
   }
   ```
4. Keymaps: nothing to add. The global `dap.lua` `keys` table (`<Leader>db`,
   `<Leader>dc`, `<F5>`, …) already works for any filetype — `<leader>dc`
   just shows whatever's registered under `dap.configurations.go`.

That's the entire pattern — the only per-language decisions are the adapter's
launch mechanism (here, `dlv dap` speaking DAP natively over a TCP port,
similar to how `codelldb` works) and what configurations make sense.

## 5. Verifying a new adapter

- `:DapShowLog` opens the adapter's log — the first stop when a session
  won't start.
- `nvim --headless -c "lua print(vim.inspect(require('dap').adapters))" -c "qa"`
  confirms the adapter table is registered as expected.
- Actually start a session (`<leader>dc` or `<F5>`) against a real program
  built with debug symbols before considering it done.
