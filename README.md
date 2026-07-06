# Neovim configuration

A standalone Neovim configuration managed with the built-in plugin manager
[`vim.pack`](https://neovim.io/doc/user/pack.html). Migrated from an AstroNvim
(lazy.nvim) setup — the framework was removed and its behavior reimplemented
directly, so there are no framework abstractions between you and the plugins.

## Requirements

- **Neovim ≥ 0.12** (uses `vim.pack`, `vim.lsp.config`/`vim.lsp.enable`, and the
  nvim-treesitter `main` branch).
- `git`, a C compiler (for treesitter parsers), and a Nerd Font.
- Optional per-feature tools: `ripgrep`, `lazygit`, `lazydocker`, `uv` (Python
  debugging), `jj`, cross/embedded GDB toolchains (DAP).

## Layout

```
init.lua                 leader keys, then require the modules below
lua/bootstrap.lua        vim.pack.add for every plugin + PackChanged build hooks
lua/config/
  options.lua            editor options
  diagnostics.lua        vim.diagnostic.config
  autocmds.lua           yank highlight, cursor restore, auto-mkdir, q-to-close…
  keymaps.lua            global (non-LSP) mappings
  lsp.lua                native LSP engine (attach maps, format-on-save, features)
  vscode.lua             vscode-neovim mappings (no-op outside VS Code)
lua/plugins/*.lua        one module per plugin (or small group); each setup()s it
lua/plugins/lang/*.lua   rust / cpp / java language tooling
lua/dap_uv.lua           Python DAP via uv
after/ftplugin/*.lua     buffer-local rust/cpp keymaps
```

## Managing plugins

Plugins are declared in `lua/bootstrap.lua`. Common commands:

- `:lua vim.pack.update()` — update plugins (review in the confirm buffer, `:w`
  to apply). Also on `<Leader>pu`.
- `<Leader>ps` — list installed plugins.
- `:lua vim.pack.del({ "name" })` — remove a plugin (after deleting its spec).
- `nvim-pack-lock.json` pins revisions and is tracked in git for reproducibility.

Build steps (`LuaSnip`, `avante.nvim`) run automatically via a `PackChanged`
autocommand after install/update. On a brand-new machine, run `nvim` once to let
everything install/build, then restart.

Language servers, formatters and debuggers are installed with Mason
(`:Mason`, or `<Leader>pm`).

## Notes

- Leader is `<Space>`, local leader is `,`.
- Statusline is lualine; file tree is neo-tree (`<Leader>e`); fuzzy finding is
  snacks picker (`<Leader>f…`).
- Debugging is nvim-dap with VS Code-style function keys; see `docs/dap-guide.md`.
