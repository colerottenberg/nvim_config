# Adding a language server

How to get a new LSP server attached in this config — whether it's a
Mason-managed server that needs no customization, or one you want to install
and configure entirely yourself.

---

## 1. How this actually works (no `require('lspconfig').setup{}` here)

This config uses only the **native Neovim 0.11+ LSP API** —
`vim.lsp.config()` / `vim.lsp.enable()` — never the older
`require('lspconfig').<server>.setup{}` pattern. There is no
`require("lspconfig")` call anywhere in this repo.

`nvim-lspconfig` is still a dependency, but only as a **library of static
config files**: one Lua file per server at `lsp/<name>.lua` inside the
plugin, e.g. `lsp/clangd.lua`, `lsp/buck2.lua`. Each is nothing but a table —
`cmd`, `filetypes`, `root_markers`, sometimes `settings`. No logic, no
install step.

The "registry" is Neovim's own runtime path. `vim.lsp.enable("clangd")`
resolves the server's config by calling
`vim.api.nvim_get_runtime_file("lsp/clangd.lua", true)`, which returns
**every** matching file across your entire `'runtimepath'`, and merges them
in rtp order with `vim.tbl_deep_extend("force", ...)` — later entries win.
Since `after/` directories are always scanned last, **a config directory's
own `after/lsp/<name>.lua` always overrides whatever a plugin (like
nvim-lspconfig) ships** for that server name. No plugin API involved — this
is built into Neovim itself (confirmed against `$VIMRUNTIME/lua/vim/lsp.lua`
on Neovim 0.12).

This is why the convention below has two independent axes:
- **Where the config table comes from** — nvim-lspconfig's bundled default,
  your own `after/lsp/<name>.lua`, or an inline `vim.lsp.config(name, {...})`
  call.
- **How the server gets enabled** — automatically via `mason-lspconfig`'s
  `automatic_enable` (only for Mason-installed servers), or explicitly via
  your own `vim.lsp.enable("<name>")` call.

## 2. Path A — Mason-managed, no custom behavior

The simple case: the server just needs installing, nvim-lspconfig's bundled
default config is fine as-is.

1. Add the Mason package name to `ensure_installed` in
   `lua/plugins/lsp.lua`'s `mason-tool-installer.setup{}` call.
2. Done. `mason-lspconfig`'s `automatic_enable` (configured in the same file)
   calls `vim.lsp.enable(name)` for every Mason-installed server automatically
   — no file to create, no `vim.lsp.config` call needed, unless you also want
   to override a setting (see Path B).

## 3. Path B — hand-configured server, via `after/lsp/<name>.lua`

Use this when you need a custom `cmd`, `root_markers`, `filetypes`, or
`settings`, or want to **bypass Mason entirely** and control installation
yourself (a system package, `cargo install`, a project's own toolchain
binary, etc.).

1. **Get the binary on `PATH`** however you choose — Mason is not required.
2. **Write `after/lsp/<name>.lua`**, returning a plain config table:
   ```lua
   return {
     cmd = { "your-server", "--stdio" },
     filetypes = { "yourft" },
     root_markers = { "your.config.file", ".git" },
   }
   ```
   If nvim-lspconfig already ships a default for this server name, your file
   *merges over* it (only the keys you set are overridden); if not, this is
   the entire config.
3. **Enable it explicitly**: add `vim.lsp.enable("<name>")` in
   `lua/config/lsp.lua`, next to the existing `vim.lsp.enable "ruff"` line.
   `vim.lsp.enable` just registers eligibility — the client only actually
   attaches when a buffer's filetype/root matches, so this is safe to call
   unconditionally at startup even if the binary isn't installed yet.
4. **Prevent Mason from double-managing it**: if there's a same-purpose
   Mason package that `mason-lspconfig` could auto-enable (e.g. an
   alternate/competing server for the same filetype), add its name(s) to
   `automatic_enable.exclude` in `lua/plugins/lsp.lua` so it can never
   attach alongside your hand-rolled config.

### Worked example: Buck2, via its built-in `buck2 lsp` subcommand

[Buck2](https://buck2.build/) ships its own language server as a subcommand
of the `buck2` binary itself — there's no separate package to install, and no
Mason package exists for it. nvim-lspconfig does ship a bundled
`lsp/buck2.lua` (`cmd = {"buck2","lsp"}`, `filetypes = {"bzl"}`,
`root_markers = {".buckconfig"}`), but two things were missing to make it
actually work end-to-end in this config: nothing enabled it, and nothing
mapped `BUCK`/`TARGETS` files (which have no extension) to filetype `bzl`.

This repo now wires it up as the canonical example of Path B:

- **`after/lsp/buck2.lua`** — overrides the bundled default, adding `.git` as
  a fallback root marker:
  ```lua
  return {
    cmd = { "buck2", "lsp" },
    filetypes = { "bzl" },
    root_markers = { ".buckconfig", ".git" },
  }
  ```
- **`lua/config/autocmds.lua`** — `vim.filetype.add` maps `BUCK`, `TARGETS`,
  and `*.bxl` to filetype `bzl`, since none of those are Neovim's built-in
  Starlark/`bzl` detection.
- **`lua/config/lsp.lua`** — `vim.lsp.enable "buck2"`, alongside `ruff`, since
  no Mason package backs it.
- **`lua/plugins/lsp.lua`** — `automatic_enable.exclude` includes
  `"starlark_rust"`, `"starpls"`, `"bzl"`, `"bazelrc_lsp"` — the
  Mason-known Bazel/Starlark servers — so none of them can ever attach
  alongside (or instead of) the hand-configured `buck2` server if one of
  those packages gets installed later.

The result: open a `BUCK`/`TARGETS`/`*.bzl` file inside a directory with a
`.buckconfig`, and `buck2 lsp` attaches — entirely outside Mason's install
pipeline, fully under your control.

## 4. Path C — server setup tangled with a real plugin

Some servers are better owned by a dedicated plugin rather than raw
`vim.lsp.config`/`enable` calls, because the plugin does more than just start
the server (project detection, custom commands, DAP integration, etc.). This
repo already does this for:

- **`rust_analyzer`** — owned by `rustaceanvim` (`lua/plugins/lang/rust.lua`),
  configured via the `vim.g.rustaceanvim` global rather than `vim.lsp.config`.
  Never enabled directly; excluded from `automatic_enable`.
- **`jdtls`** — owned by `nvim-java` (`lua/plugins/lang/java.lua`), which
  calls `require("java").setup()` before `vim.lsp.enable "jdtls"` itself.
  Also excluded from `automatic_enable`.
- **`clangd`** — a hybrid: Mason-installed and `automatic_enable`d normally,
  but `lua/plugins/lang/cpp.lua` adds an inline `vim.lsp.config("clangd", {...})`
  override (for `offsetEncoding`) plus a scoped `LspAttach` autocmd for an
  extra keymap, because it's paired with `clangd_extensions.nvim`.

**Rule of thumb**: put server config in `lua/plugins/lang/<lang>.lua` when
it's tangled with a real plugin that needs its own `init`/`config` function;
put it in `after/lsp/<name>.lua` when it's just server configuration with no
accompanying plugin. `clangd`'s inline `vim.lsp.config` call is a reasonable
candidate to migrate to `after/lsp/clangd.lua` for consistency — see
[`ROADMAP.md`](ROADMAP.md).

## 5. Verifying a new server

- `:LspInfo` (or `:checkhealth vim.lsp`) shows attached clients for the
  current buffer.
- `nvim --headless -c "lua print(vim.inspect(vim.lsp.config.<name>))" -c "qa"`
  — inspect the fully merged config without opening a real buffer.
- Open a file that should match `filetypes`/`root_markers` and confirm the
  client attaches (`:LspInfo`) with the `cmd` you expect.
