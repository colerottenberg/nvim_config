# Roadmap

Forward-looking configurability/usability work for this config. Not
implemented yet — a punch list, not a spec. Pull from here into actual
changes as they get done; strike items out or delete them once landed.

## LSP configurability

- [ ] Migrate `clangd`'s inline `vim.lsp.config` override
      (`lua/plugins/lang/cpp.lua`) to `after/lsp/clangd.lua`, for consistency
      with the `after/lsp/` convention introduced for `buck2`
      (see [`adding-a-language-server.md`](adding-a-language-server.md)).
- [ ] Add a `:checkhealth`-style report distinguishing "enabled" (
      `vim.lsp.config` registered) vs. "attached" (actually running for the
      current buffer) servers, so the Mason/hand-config split is legible at a
      glance instead of requiring `:LspInfo` per buffer.
- [ ] Consider whether `lua_ls` needs an explicit `after/lsp/lua_ls.lua` now
      that this repo has a documented convention for it — currently it has no
      override at all and relies purely on the bundled default plus `.neoconf.json`.

## DAP configurability

- [ ] Populate `mason-nvim-dap`'s `ensure_installed` further as new adapters
      get added (currently `codelldb`, `debugpy`) so a fresh machine doesn't
      need manual `:Mason` runs.
- [ ] Add Go (`delve`) support, following the template in
      [`adding-a-debug-adapter.md`](adding-a-debug-adapter.md) §4.
- [ ] Add JS/TS support (`js-debug-adapter` + `pwa-node` configs).
- [ ] Firm up the "inline in `dap.lua`" vs. "dedicated `lua/dap_<lang>.lua`
      module" decision into a documented rule rather than case-by-case (see
      [`adding-a-debug-adapter.md`](adding-a-debug-adapter.md) §2 for the
      current three-pattern breakdown).

## General usability / hygiene

- [ ] Add a custom `:checkhealth` module validating external tool
      availability (`git`, `ripgrep`, `uv`, GDB toolchains, `buck2`,
      `lazygit`/`lazydocker`) with actionable install hints, instead of
      failing silently/cryptically when a feature-gated tool is missing.
- [ ] Add `CONTRIBUTING.md` documenting the `stylua`/`selene` conventions
      (`.stylua.toml`, `selene.toml`, `neovim.yml` already exist but nothing
      runs them automatically).
- [ ] Consider CI (GitHub Actions) running `stylua --check` and `selene` on
      push/PR — no CI exists today.
- [ ] Consider a `CHANGELOG.md`, or lean on conventional commit messages,
      given this config changes continuously.
- [ ] Verify the Nerd Font requirement in `README.md` is specific enough
      (v3+, for Codicon-based icon sets like aerial.nvim's symbol kinds) —
      tofu-box rendering was observed and traced to this during this pass.
