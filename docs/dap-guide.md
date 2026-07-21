# Debugging guide for this Neovim config

How DAP is wired up here, and how to add/drive debuggers for Python, native
C/C++, an embedded Linux target over `gdbserver`, and an ESP32 over OpenOCD.

For the protocol-level background (what a debug adapter is, the DAP wire format
and session lifecycle), see [`dap-protocol.md`](./dap-protocol.md).

---

## 1. What you already have

| Piece | Where | Role |
|---|---|---|
| `nvim-dap` | `lua/plugins/dap.lua` | The DAP **client**. Talks the protocol to each adapter. |
| `nvim-dap-ui` + `nvim-nio` | same file | Scopes / stacks / breakpoints / watches UI. Auto-opens on session start. |
| `mason-nvim-dap` | dependency of `lua/plugins/dap.lua`, `ensure_installed = { "codelldb", "debugpy" }` | Installs adapters and registers sensible defaults. |
| `rustaceanvim` | `lua/plugins/lang/rust.lua` | **Owns Rust debugging** — auto-configures the `codelldb` adapter via `vim.g.rustaceanvim.dap`. Don't hand-roll Rust DAP. |
| `codelldb`, `debugpy` | installed in Mason (auto via `ensure_installed` above) | The actual adapters used below. |
| `dap_py` | `lua/dap_py.lua` | Python debugging through `uv`-managed envs (this repo's module; loaded only for Python buffers via `after/ftplugin/python.lua`). |

Leader is `<Space>`, local-leader is `,`.

### Keymaps (`<leader>d…`)

| Key | Action |
|---|---|
| `db` / `dB` | toggle breakpoint / conditional breakpoint |
| `dc` | continue / **start** (shows a picker of all configs for the filetype) |
| `di` / `do` / `dO` | step into / over / out |
| `dr` | toggle REPL |
| `dl` | run last configuration |
| `dq` | terminate session |
| `du` | toggle dap-ui |
| `<Leader>uI` | toggle inline variable values (virtual text) |
| `de` | eval expression under cursor / visual selection |

Python has its own buffer-local keymaps (set in `after/ftplugin/python.lua`,
only active in Python buffers), under local-leader (`,`): `,f` debug current
file, `,t` / `,T` pytest current file / whole suite, `,c` / `,C` run a CLI
entry point / list entry points (all via `dap_py`).

Function keys (VS Code-style): `<F5>` continue/start · `<S-F5>` terminate ·
`<F6>` pause · `<F9>` toggle breakpoint · `<F10>` step over · `<F11>` step into ·
`<S-F11>` step out.

> **Where the function keys are defined — and a terminal gotcha.** They live in
> the nvim-dap `keys` field in `lua/plugins/dap.lua` (lines ~126-144), right
> alongside the rest of the DAP keymaps. Most terminals send **Shift+F5 as
> `<F17>`** and **Shift+F11 as `<F23>`** (legacy xterm F13–F24 encoding); newer
> terminals (kitty/CSI-u protocol) send `<S-F5>`/`<S-F11>`. We bind *both*
> encodings so the shifted keys work regardless of terminal. To see what your
> terminal actually sends, run `nvim -V3log +q` and grep the log for the key.

`<leader>dc` is the workhorse: it lists every configuration registered for the
current buffer's filetype and lets you pick one.

---

## 2. The mental model: adapter + configurations

Adding any debugger is always the same two steps, either inline in the
`config` function of `lua/plugins/dap.lua` or inside a dedicated module (see
[`adding-a-debug-adapter.md`](adding-a-debug-adapter.md) for when to use
which):

```lua
-- (a) An ADAPTER: how nvim-dap launches/reaches the debug adapter process.
dap.adapters.<name> = { type = "executable" | "server", ... }

-- (b) One or more CONFIGURATIONS per language: what to debug.
dap.configurations.<filetype> = { { type = "<name>", request = "launch"|"attach", ... } }
```

`type` in a configuration must match an adapter key. Any value in a
configuration may be a **function** — nvim-dap calls it when you start the
session and uses the return value (used below for `vim.fn.input` prompts and
process pickers).

Two request kinds:

- **`launch`** — the adapter starts the program for you.
- **`attach`** — the program (or a `gdbserver`/OpenOCD) is *already running*; the
  adapter connects to it. All the remote/embedded flows are `attach`.

---

## 3. Python (`debugpy` via `uv`) — `lua/dap_py.lua`

`after/ftplugin/python.lua` calls `require("dap_py").setup()` (only when a
Python buffer is opened), which registers a `python` adapter that launches
`debugpy.adapter` **inside your project env** via:

```sh
uv run --with debugpy -- python -m debugpy.adapter
```

`--with debugpy` injects debugpy ephemerally, so **you don't need to add it as a
project dependency** — and the debuggee still sees all your project's deps
because `uv run` syncs the project env first.

**Registered configurations** (all in the `<leader>dc` picker):

| Config | What it does |
|---|---|
| *file: current* | launch the current file (`,f`) |
| *file: current + dir* | …prompting for a working directory |
| *file: current + args* | …prompting for CLI args |
| *file: current + args + dir* | …prompting for both, dir first |
| *module: -m ...* | prompt for a module (`python -m pkg.main`) + args |
| *cli: entry point* (+ *dir*) | run a `.venv/bin/<name>` console-script entry point (`,c`) |
| *cli: list entry points* (+ *dir*) | pick an entry point from `.venv/bin` (`,C`) |
| *pytest: current file* | `pytest ${file}` (`,t`) |
| *pytest: current file (filter)* | …prompting for a `-k` filter |
| *pytest: whole suite* | `pytest` over the project (`,T`) |
| *attach: localhost:5678* | connect to a local debugpy listener |
| *attach: remote (host:port)* | connect to a container/remote listener (with path mapping) |

**Per project:** just `uv sync` (and have `pytest` as a dep for the pytest
configs). No `uv add --dev debugpy` needed.

**Attach to a running process** — start it with debugpy listening:

```sh
uv run --with debugpy python -m debugpy --listen 5678 --wait-for-client app.py
```

then pick *attach: localhost:5678*. For a container, expose the port and pick
*attach: remote (host:port)*; it maps `${workspaceFolder}` ↔ the remote source
root so breakpoints bind (adjust `pathMappings` in `lua/dap_py.lua` if your code
lives somewhere other than the remote CWD).

> If `uv` isn't on `PATH`, the adapter falls back to an active venv → `.venv/bin/python` → `python3` (debugpy must then be installed in that interpreter).

---

## 4. Native local C/C++ (`codelldb`)

Already the default for `c`/`cpp` buffers. Open a source file, build with debug
info (`-g`, e.g. `cmake -DCMAKE_BUILD_TYPE=Debug`), then:

- `<leader>dc` → **codelldb: launch local executable** → enter the path to your
  binary (defaults to `./build/`).
- **codelldb: attach to running process** → pick a PID from the list.

`codelldb` (LLDB-based) is the most ergonomic choice for local native debugging
and is what `rustaceanvim` uses under the hood for Rust.

---

## 5. Local C/C++ with GDB's native DAP

GDB **14.1+** speaks DAP directly via `--interpreter=dap`. Check your version:

```sh
gdb --version    # must be >= 14.1
```

Configs (pick with `<leader>dc`):

- **gdb: launch local executable** — enter the binary path; GDB runs it.
- **gdb: attach to running process** — pick a PID, then the matching local ELF.

Use this when you want GDB semantics (pretty-printers, `gdbinit`, language
support LLDB lacks) rather than LLDB.

---

## 6. Embedded Linux target over `gdbserver`

For a board running a custom Linux distro, you debug **remotely**: a small
`gdbserver` runs on the device, and a *cross* GDB on your machine connects to it
and uses the local ELF (with symbols) for source-level debugging.

### On the device

```sh
# launch the program under gdbserver, listening on TCP 3333
gdbserver :3333 /usr/bin/your_app arg1 arg2
# …or attach to something already running:
gdbserver :3333 --attach <pid>
```

### On your machine

Point the config at the right cross GDB. Set it via env var (or edit
`EMBEDDED_GDB` at the top of the `config` function in `lua/plugins/dap.lua`):

```sh
export CROSS_GDB=aarch64-poky-linux-gdb     # e.g. from your Yocto/Buildroot SDK
```

> The cross GDB must (a) match the target architecture and (b) be **GDB ≥ 14.1**
> so it has the DAP interpreter. SDK GDBs are often older — if so, build/install
> a newer cross GDB, or use the `cppdbg` fallback in §8.

Then `<leader>dc` → **gdb: attach embedded Linux (gdbserver)**:

- *Local ELF (with symbols)* — the unstripped binary you built for the target
  (its on-device copy may be stripped; GDB reads symbols from the local one).
- *gdbserver target (host:port)* — e.g. `192.168.1.50:3333`. This string is
  handed straight to GDB's `target remote`.

For sysroot-heavy setups (resolving shared-lib symbols), add a `gdbinit` with
`set sysroot /path/to/sdk/sysroot` and pass it via the adapter args
(`-x /path/to/gdbinit`).

---

## 7. ESP32 over OpenOCD

ESP32 debugging is the same remote-GDB pattern, but **OpenOCD** is the GDB server
(speaking JTAG/USB to the chip) instead of `gdbserver`.

### Prerequisites

- Espressif toolchain GDB for your chip family, on `PATH` or via `ESP_GDB`:
  - Xtensa (ESP32 / S2 / S3): `xtensa-esp-elf-gdb`
  - RISC-V (C3 / C6 / H2 / P4): `riscv32-esp-elf-gdb` → `export ESP_GDB=riscv32-esp-elf-gdb`
- It must be **GDB ≥ 14.1** for `--interpreter=dap` (ESP-IDF ≥ v5.3 ships this).
- OpenOCD with ESP support (bundled with ESP-IDF).

### Start the OpenOCD GDB server (separate terminal)

```sh
# inside an ESP-IDF project (simplest — picks the right board cfg):
idf.py openocd

# …or directly:
openocd -f board/esp32-wrover-kit-3.3v.cfg     # pick the cfg for your board
```

OpenOCD exposes the GDB server on `localhost:3333`.

### Connect from Neovim

Open a `c`/`cpp` file, `<leader>dc` → **gdb: attach ESP32 (OpenOCD :3333)**, and
give it your app ELF (defaults to `./build/`). It connects to `localhost:3333`.

> **Tip — reset/flash on connect.** Bare `attach` connects to the running chip.
> To halt-reset and break at boot, add an ESP gdbinit and pass it via the
> adapter args, e.g. set `dap.adapters.gdb_esp.args` to
> `{ "--quiet", "--interpreter=dap", "-x", vim.fn.expand("~/.config/nvim/gdbinit.esp") }`
> with the gdbinit containing `mon reset halt`, `flushregs`, `thb app_main`.

### A note on "ESP32 DAP"

"DAP" is overloaded here. This guide uses the **Debug Adapter Protocol** (GDB's
`--interpreter=dap`) on top of OpenOCD's GDB server. That is distinct from
**CMSIS-DAP**, a *hardware* debug-probe protocol (e.g. ESP-Prog, or the
`esp-dap`/wireless-esp firmware that turns an ESP into a CMSIS-DAP probe). If
you use a CMSIS-DAP probe, it changes only the OpenOCD interface config
(`-f interface/cmsis-dap.cfg`); the Neovim side is unchanged.

---

## 8. Adding more debuggers / fallbacks

**Pattern recap:** install the adapter (Mason, via `ensure_installed` in
`lua/plugins/dap.lua`'s `mason-nvim-dap.setup{}` call — currently
`{ "codelldb", "debugpy" }` — or manually), define `dap.adapters.<x>`, add
entries to `dap.configurations.<ft>`. See
[`adding-a-debug-adapter.md`](adding-a-debug-adapter.md) for a full worked
example (Go/delve) and guidance on inline-vs-dedicated-module placement.

- **Go:** not configured yet. `:MasonInstall delve`, then a `dap.adapters.delve`
  server adapter + `dap.configurations.go` — see
  [`adding-a-debug-adapter.md`](adding-a-debug-adapter.md).
- **JS/TS:** not configured yet. `js-debug-adapter` (Mason) + `pwa-node` configs.
- **`cppdbg` (cpptools) fallback for remote GDB:** if your SDK GDB predates 14.1
  (no DAP), install `cpptools` (`:MasonInstall cpptools`) and use its `cppdbg`
  adapter with `miDebuggerPath = "<cross-gdb>"` and
  `miDebuggerServerAddress = "host:3333"`. This drives an *old* GDB over MI, so
  no GDB ≥ 14.1 requirement — the classic VS Code remote-embedded approach.

---

## 9. Troubleshooting

- **`:DapShowLog`** opens the adapter log — first stop for "session won't start".
- **GDB DAP does nothing / "interpreter dap not found"** — your GDB is < 14.1.
- **codelldb can't find the binary** — build with `-g`; give an absolute path.
- **Remote attach connects but no symbols** — you pointed at a stripped binary;
  use the unstripped local ELF, and set `sysroot` for shared libraries.
- **ESP32 `target remote` refused** — OpenOCD isn't running / not on `:3333`, or
  the board cfg is wrong for your chip.
