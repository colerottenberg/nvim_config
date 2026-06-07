# How debug adapters work — the Debug Adapter Protocol (DAP)

Deep-dive reference on the protocol that `nvim-dap` (and VS Code, and most modern
editors) speak to debuggers. For the practical setup in *this* config, see
[`dap-guide.md`](./dap-guide.md).

> **Provenance.** The core claims below were checked against the official
> Microsoft DAP specification and overview; sentences marked **[spec ✓]** were
> verified verbatim against a primary source (quotes and URLs in §10). The
> automated fact-checker exhausted its API credits before the final verification
> pass, so the lifecycle/wire-format details beyond the quoted claims are written
> from the specification directly rather than from an independent second vote —
> treat the **[spec ✓]** lines as the highest-confidence statements.

---

## 1. The problem DAP solves

Before DAP, every editor that wanted to debug language X had to implement glue
for X's specific debugger (GDB/MI, lldb, the V8 inspector, debugpy, delve…). That
is an *M editors × N debuggers* integration matrix.

DAP collapses it to *M + N*. **[spec ✓]** DAP is an abstract, JSON-based protocol
defined by Microsoft that standardizes communication between a development tool
(IDE/editor) and a debugger, using an intermediary "Debug Adapter" to adapt an
existing debugger or runtime to the protocol. The editor implements one DAP
*client*; each debugger gets wrapped once by a *debug adapter*. This is the exact
same decoupling philosophy as the Language Server Protocol (LSP), from the same
team.

The key design insight, in the spec's own words: since it's unrealistic to expect
existing debuggers to adopt the protocol natively, an intermediary component — the
debug adapter — adapts an existing debugger or runtime to DAP.

---

## 2. Architecture: the three layers

**[spec ✓]** DAP introduces an intermediary "debug adapter" component that adapts
an existing debugger or runtime API to the protocol, forming a three-layer
architecture:

```
┌─────────────────────┐   DAP over     ┌──────────────────┐   debugger-native   ┌────────────────┐
│  Development tool    │  stdio / TCP   │  Debug Adapter   │   API / protocol    │ Debugger /     │
│  (IDE / editor)      │ ◄────────────► │  (the "adapter") │ ◄─────────────────► │ runtime        │
│  = the DAP *client*  │   JSON msgs    │                  │  (MI, ptrace, …)    │ (gdb, lldb, …) │
│  e.g. nvim-dap       │                │ e.g. codelldb,   │                     │                │
└─────────────────────┘                │ debugpy, gdb-dap │                     └────────────────┘
                                        └──────────────────┘
```

- **Development tool / client** — owns the UI: breakpoint gutter, variables pane,
  stepping commands. In this config that's **nvim-dap** + **nvim-dap-ui**.
- **Debug adapter** — a process that translates DAP requests into whatever the
  real debugger understands, and translates the debugger's stops/output back into
  DAP events. Examples: `codelldb` (wraps LLDB), `debugpy` (Python), and GDB's
  own built-in `--interpreter=dap` mode (GDB ≥ 14.1, where adapter and debugger
  are the same process).
- **Debugger / runtime** — does the actual work: sets hardware/software
  breakpoints, reads registers and memory, controls execution.

The adapter can be written in whatever language best fits the debugger, because
DAP is a *wire protocol*, not a client library. The boundary that matters is the
DAP boundary; everything to the right of the adapter is the debugger's own world
(GDB/MI, ptrace, JTAG via OpenOCD, etc.).

### Protocol vs. underlying debugger

DAP deliberately does **not** define how breakpoints are physically set or how
memory is read — those are the debugger's job. DAP defines only the *vocabulary*
the editor uses to ask for them (`setBreakpoints`, `variables`, `stepIn`, …) and
the *events* the adapter emits (`stopped`, `output`, `terminated`). This is why a
single nvim-dap UI works identically whether the bytes underneath come from LLDB
on your laptop or GDB talking to a microcontroller over JTAG.

---

## 3. The wire format

**[spec ✓]** The DAP wire format uses an HTTP-like structure with a header and a
content part separated by `\r\n`; the header is ASCII-encoded with a required
`Content-Length` field, and the content part is UTF-8-encoded JSON.

A single message on the wire looks like:

```
Content-Length: 119\r\n
\r\n
{"seq":153,"type":"request","command":"next","arguments":{"threadId":3}}
```

- The header block is terminated by a blank `\r\n`; `Content-Length` (byte count
  of the JSON body) is the only required header field.
- The body is JSON. This framing is the same idea LSP uses — and is similar to,
  but **not** the same as, JSON-RPC. DAP defines its own message envelope.

### Three message types

Every DAP message is a `ProtocolMessage` carrying a monotonically increasing
`seq` (sequence number) and a `type`. The three types:

| `type` | Direction | Shape |
|---|---|---|
| `request` | client→adapter (mostly) or adapter→client (reverse) | `command` + optional `arguments` |
| `response` | reply to a request | `request_seq`, `success`, `command`, optional `body` / `message` |
| `event` | adapter→client, unsolicited | `event` name + optional `body` |

Responses reference the request they answer via `request_seq`, so the transport
can be fully asynchronous: the client may have many requests in flight, and the
adapter may interleave events (e.g. `output`) between them.

---

## 4. Capabilities negotiation

**[spec ✓]** The `initialize` request is the first message sent from the client to
the debug adapter; it both configures the adapter with client capabilities and
retrieves the adapter's capabilities. This two-way handshake is how each side
learns what the other supports — e.g. the adapter advertises
`supportsConfigurationDoneRequest`, `supportsConditionalBreakpoints`,
`supportsFunctionBreakpoints`, `supportsSetVariable`, and dozens more boolean
`Capabilities` flags. The client adapts its behaviour accordingly (e.g. only
sends `configurationDone` if the adapter says it supports it).

Client-side capabilities travel in `InitializeRequestArguments` (fields such as
`linesStartAt1`, `columnsStartAt1`, `supportsRunInTerminalRequest`,
`supportsStartDebuggingRequest`). The adapter's capabilities come back in the
`initialize` **response body**.

---

## 5. The session lifecycle

This is the canonical sequence. Items in **bold [spec ✓]** are spec-verified
verbatim; the connective tissue is from the specification's documented ordering.

```
client (nvim-dap)                         adapter (codelldb / debugpy / gdb-dap)
      │                                            │
      │ ── initialize (client capabilities) ─────► │   [spec ✓] first message
      │ ◄──────── initialize response (caps) ───── │   capabilities negotiation
      │                                            │
      │ ── launch  OR  attach ───────────────────► │   request is sent, not yet answered
      │ ◄──────────────── initialized (event) ──── │   [spec ✓] "ready for config requests"
      │                                            │
      │ ── setBreakpoints ───────────────────────► │   ┐ configuration phase
      │ ── setFunctionBreakpoints (if supported) ─► │   │  (per source file etc.)
      │ ── setExceptionBreakpoints ──────────────► │   │
      │ ── configurationDone ────────────────────► │   ┘ ends configuration
      │                                            │
      │ ◄────────── launch/attach response ─────── │   session is now live; debuggee runs
      │                                            │
      │ ◄──────────────── stopped (event) ──────── │   [spec ✓] hit breakpoint / step done
      │ ── threads ──────────────────────────────► │   ┐
      │ ── stackTrace (threadId) ────────────────► │   │ the "info waterfall" the UI
      │ ── scopes (frameId) ─────────────────────► │   │ runs on every stop to populate
      │ ── variables (variablesReference) ───────► │   ┘ dap-ui panes
      │                                            │
      │ ── continue / next / stepIn / stepOut ───► │   resume; loops back to `stopped`
      │                                            │
      │ ── disconnect (and/or terminate) ────────► │   end of session
      │ ◄──────────────── terminated (event) ───── │   debuggee gone
```

Key points:

- **The `initialized` event is a signal, not the response to `initialize`.**
  **[spec ✓]** The debug adapter emits an `initialized` event to signal it is
  ready to receive configuration-phase requests such as `setBreakpoints` and
  `setExceptionBreakpoints`. Crucially the client sends `launch`/`attach`
  *before* this event arrives, but the adapter only finishes starting the session
  after the client closes configuration with `configurationDone`.
- **The configuration phase** is where breakpoints are registered. `setBreakpoints`
  is sent once per source file and *replaces* all breakpoints for that file (it's
  declarative, not incremental). The adapter's response reports which breakpoints
  were actually `verified` (bound to real code).
- **`stopped` drives everything visible.** **[spec ✓]** The `stopped` event tells
  the client that debuggee execution has halted — caused by a previously set
  breakpoint, a completed stepping request, a `debugger` statement, etc. Its body
  carries the `reason` (`"breakpoint"`, `"step"`, `"exception"`, `"pause"`…) and
  the `threadId`. nvim-dap reacts by requesting `threads` → `stackTrace` →
  `scopes` → `variables` to fill the UI. Nested data (structs, objects) is fetched
  lazily: each variable that has children carries a `variablesReference` you
  expand on demand.
- **Stepping**: `continue`, `next` (step over), `stepIn`, `stepOut`, `pause`. Each
  resumes the debuggee; the next `stopped` event restarts the waterfall.
- **Teardown**: `disconnect` ends the DAP session; for launched programs the
  client may first send `terminate` to kill the debuggee gracefully. The adapter
  fires a `terminated` event when the debuggee is gone. `restart` is an optional
  capability.

---

## 6. Launch vs. attach

**[spec ✓]** DAP distinguishes **launch** (the adapter starts the debuggee in
debug mode) from **attach** (the adapter connects to an already-running program);
whenever the program stops, the adapter emits a `stopped` event.

- **`launch`** — you hand the adapter a `program` (and `args`, `cwd`, `env`); it
  starts the process under debugger control. The exact argument schema is
  **adapter-specific** — DAP intentionally leaves `LaunchRequestArguments` mostly
  open, which is why a codelldb launch config and a debugpy launch config have
  different fields.
- **`attach`** — the process already exists. You point the adapter at it by `pid`,
  or, for remote debugging, by a server address. This is the basis of every
  remote/embedded flow: GDB's DAP `attach` takes a `target` string passed to
  `target remote`, so a `gdbserver` on a device or OpenOCD on `:3333` is just an
  attach target (see [`dap-guide.md`](./dap-guide.md) §6–§7).

In nvim-dap both are just entries in `dap.configurations.<filetype>` with
`request = "launch"` or `request = "attach"`.

---

## 7. Reverse requests

Normally requests flow client→adapter. DAP also defines **reverse requests** that
flow the other way, adapter→client, for things only the editor can do.

**[spec ✓]** DAP includes reverse requests that flow from the debug adapter to the
client: `runInTerminal` asks the client to run a command in a terminal, and
`startDebugging` asks the client to start a new debug session.

- **`runInTerminal`** — the adapter can't (and shouldn't) own a TTY. To give the
  debuggee a real interactive terminal — `stdin`, job control, a pty — it asks the
  *client* to spawn the process in a terminal the user can see. This is why
  `console = "integratedTerminal"` in a debugpy/python config (as `dap_uv` uses)
  works: debugpy issues `runInTerminal` and nvim-dap opens a terminal buffer.
  Gated by the client capability `supportsRunInTerminalRequest`.
- **`startDebugging`** — lets an adapter spin up *child* sessions: multi-process
  debugging, a worker/subprocess, or a forked child. The adapter asks the client
  to start a new session that shares the same connection. Gated by
  `supportsStartDebuggingRequest`.

Because reverse requests are still ordinary DAP `request` messages (just with the
direction flipped), the same `seq`/`request_seq` correlation applies — the client
sends back a normal `response`.

---

## 8. History & origin

DAP came out of Microsoft's work on Visual Studio Code. VS Code needed to debug
many languages without baking each debugger into the editor, so the team
generalized the adapter pattern they'd built for individual debuggers into a
documented, editor-agnostic protocol and published it (the protocol's website and
`vscode-debugadapter` reference implementation went public in 2018). It is the
debugging-world sibling of LSP: same "standardize the wire protocol, let everyone
implement against it" strategy. The specification is maintained as an open,
versioned schema under Microsoft's GitHub organization, and the ecosystem of
adapters (codelldb, debugpy, delve, js-debug, GDB's native mode, …) is now broad
enough that any DAP client gets dozens of debuggers "for free."

> The widely-repeated detail that DAP's JSON envelope was *inspired by the
> (obsolete) V8 debugging protocol* is plausible and commonly cited, but the
> automated verifier could not confirm it against a primary source in this run —
> treat it as folklore-grade rather than spec-grade.

---

## 9. How nvim-dap implements a DAP client

[`nvim-dap`](https://github.com/mfussenegger/nvim-dap) is a pure-Lua DAP **client**
for Neovim. Conceptually it implements exactly the left-hand box of §2:

1. **Adapters** (`dap.adapters.<type>`) tell nvim-dap *how to reach an adapter
   process*: either `type = "executable"` (spawn a binary, speak DAP over its
   stdio — e.g. GDB's `--interpreter=dap`, debugpy) or `type = "server"` (connect
   to a TCP port the adapter listens on — e.g. `codelldb`, which nvim-dap launches
   then connects to via `${port}`). An adapter may also be a Lua *function*
   `(callback, config)` that decides at runtime (the `dap_uv` Python adapter does
   this to branch launch vs. attach).
2. **Configurations** (`dap.configurations.<filetype>`) are the `launch`/`attach`
   request bodies, one list per filetype. `dap.continue()` (your `<leader>dc`)
   shows them in a picker. Any field may be a function, evaluated when the session
   starts — that's how the configs in this repo prompt for an executable path or a
   target `host:port`.
3. **The protocol loop**: nvim-dap frames/parses `Content-Length` messages, runs
   the initialize→configure→launch handshake, registers your breakpoints via
   `setBreakpoints`, and listens for events. You can hook those events with
   `dap.listeners.after.event_initialized[...]` / `before.event_terminated[...]`
   — which is exactly how `debugging.lua` makes nvim-dap-ui open and close
   automatically.
4. **The UI** is layered on top: `nvim-dap-ui` (with `nvim-nio`) renders the
   scopes/stacks/breakpoints/watches by issuing the standard `threads` →
   `stackTrace` → `scopes` → `variables` waterfall on each `stopped` event.

Because nvim-dap only speaks DAP, adding a debugger never touches nvim-dap itself
— you only declare a new adapter + configurations, which is the entire subject of
[`dap-guide.md`](./dap-guide.md).

---

## 10. Sources (spec-verified claims)

All quotes below are from primary Microsoft DAP sources and back the **[spec ✓]**
statements above.

1. **`initialize` is first + capabilities negotiation** — *"The `initialize`
   request is sent as the first request from the client to the debug adapter in
   order to configure it with client capabilities and to retrieve capabilities
   from the debug adapter."* — <https://microsoft.github.io/debug-adapter-protocol/specification.html> (3-0)
2. **`initialized` event = ready for configuration** — *"This event indicates that
   the debug adapter is ready to accept configuration requests (e.g.
   `setBreakpoints`, `setExceptionBreakpoints`)."* — specification.html (2-0)
3. **`stopped` event semantics** — *"The event indicates that the execution of the
   debuggee has stopped due to some condition. This can be caused by a breakpoint
   previously set, a stepping request has completed, by executing a debugger
   statement etc."* — specification.html (2-0)
4. **Reverse requests** — *"`RunInTerminal` is sent from the debug adapter to the
   client to run a command in a terminal. `StartDebugging` is sent from the debug
   adapter to the client to start a new debug session."* — specification.html (3-0)
5. **Three-layer architecture / intermediary adapter** — *"a_n_ intermediary
   component takes over the role of adapting an existing debugger or runtime API
   to the Debug Adapter Protocol."* — <https://microsoft.github.io/debug-adapter-protocol/overview.html> (3-0)
6. **Wire format** — *"header and a content part (comparable to HTTP). The header
   and content part are separated by a `\r\n`."* — overview.html (2-0)
7. **Session opens with initialize → initialized** — *"debug adapter is expected
   to send an **initialized** event."* — overview.html (2-0)
8. **launch vs attach** — *"launch request: the debug adapter launches the program
   ('debuggee') in debug mode."* — overview.html (3-0)
9. **What DAP is / why an adapter exists** — *"The idea behind the Debug Adapter
   Protocol (DAP) is to abstract the way how the debugging support of development
   tools communicates with debuggers or runtimes into a protocol… an intermediary
   component — a so called Debug Adapter — adapts an existing debugger or runtime
   to the Debug Adapter Protocol."* — <https://microsoft.github.io/debug-adapter-protocol/> (3-0)

Other primary sources consulted: the DAP specification repo
(<https://github.com/microsoft/debug-adapter-protocol>), the VS Code DAP launch
blog post (<https://code.visualstudio.com/blogs/2018/08/07/debug-adapter-protocol-website>),
and the nvim-dap docs (<https://github.com/mfussenegger/nvim-dap>,
`doc/dap.txt`).
