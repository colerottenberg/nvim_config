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
  merged into Nerd Fonts as of v3.
- Optional per-feature tools: `ripgrep`, `lazygit`, `uv` (Python
  debugging), cross/embedded GDB toolchains (DAP). 
