# Neovim configuration

A standalone Neovim configuration managed with
[lazy.nvim](https://github.com/folke/lazy.nvim). Originally an AstroNvim setup;
the framework was removed and its behavior reimplemented directly, so there are
no framework abstractions between you and the plugins. Each plugin has its own
spec file with lazy-load triggers and its keymaps isolated in `keys`.

## Requirements

- **Neovim ≥ 0.12** (uses `vim.lsp.config`/`vim.lsp.enable` and the
  nvim-treesitter `main` branch).
- `git`, a C compiler (for treesitter parsers), and a **Nerd Font (v3+)** —
  some icon sets (e.g. aerial.nvim's symbol kinds) use Codicon glyphs only
  merged into Nerd Fonts as of v3; an older patched font renders those as
  tofu boxes.
- Optional per-feature tools: `ripgrep`, `lazygit`, `lazydocker`, `uv` (Python
  debugging), `jj`, cross/embedded GDB toolchains (DAP), `buck2` (Buck2 LSP).

## Layout

```
init.lua                 leader keys, config modules, then the lazy bootstrap
lua/config/
  lazy.lua               lazy.nvim clone + setup (imports plugins/ and plugins/lang/)
  options.lua             editor options
  diagnostics.lua         vim.diagnostic.config
  autocmds.lua            yank highlight, cursor restore, auto-mkdir, filetype
                          detection, q-to-close…
  keymaps.lua             plugin-independent editor mappings
  lsp.lua                 native LSP engine (attach maps, format-on-save, features,
                          non-Mason server enablement)
  vscode.lua              vscode-neovim mappings (no-op outside VS Code)
lua/plugins/*.lua         one lazy spec per plugin: trigger (event/cmd/ft/keys),
                          opts, and that plugin's keymaps in `keys`
lua/plugins/lang/*.lua    rust / cpp / java / csv language tooling
lua/dap_py.lua            Python DAP via uv
after/ftplugin/*.lua      buffer-local rust/cpp/csv/python keymaps
after/lsp/*.lua           hand-configured language server overrides (native
                          Neovim rtp convention — see docs/adding-a-language-server.md)
```

## Managing plugins

Specs live in `lua/plugins/`. The `:Lazy` UI does the rest:

- `<Leader>ps` — Lazy home (status UI), `<Leader>pi` install, `<Leader>pS` sync,
  `<Leader>pu` check for updates, `<Leader>pU` update.
- `lazy-lock.json` pins revisions and is tracked in git for reproducibility;
  `:Lazy restore` returns to the locked versions.
- Build steps (`LuaSnip`, `:TSUpdate`) run automatically on install/update. On
  a brand-new machine, run `nvim` once and let it sync.

Language servers, formatters and debuggers are installed with Mason
(`:Mason`, or `<Leader>pm`) where possible; a few servers (e.g. `ruff`,
`buck2`) are hand-configured outside Mason — see
[`docs/adding-a-language-server.md`](docs/adding-a-language-server.md).

## Notes

- Leader is `<Space>`, local leader is `,`.
- Statusline is lualine; file tree is neo-tree (`<Leader>e`); fuzzy finding is
  snacks picker (`<Leader>f…`); symbols outline is aerial.nvim (`<Leader>ln`).
- Debugging is nvim-dap with VS Code-style function keys; see
  [`docs/dap-guide.md`](docs/dap-guide.md).

## Docs

- [`docs/dap-guide.md`](docs/dap-guide.md) — how debugging is wired up here
  (Python/uv, C/C++ via codelldb & GDB, embedded Linux, ESP32).
- [`docs/dap-protocol.md`](docs/dap-protocol.md) — how the Debug Adapter
  Protocol itself works, independent of this config.
- [`docs/adding-a-debug-adapter.md`](docs/adding-a-debug-adapter.md) — how to
  add a new debugger.
- [`docs/adding-a-language-server.md`](docs/adding-a-language-server.md) — how
  to add a new language server, Mason-managed or hand-configured.
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — planned configurability/usability
  improvements.
