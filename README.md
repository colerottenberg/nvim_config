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

## Checking Rust debugger type display

`lua/plugins/lang/rust.lua` loads rustc's LLDB pretty-printers itself (see
`rust_lldb_init_commands()`), because rustaceanvim's `load_rust_types` breaks
launches on toolchains whose `lldb_commands` file has blank lines. To verify it
on a new machine:

1. Inside a Rust project, check what will be sent to LLDB. Expect an
   `lldb_lookup.py` import, optionally followed by `type …` lines, and no `""`
   entries (`{}` means `rustc --print sysroot` failed):

   ```vim
   :lua =vim.g.rustaceanvim.dap.configuration().initCommands
   ```

2. `cargo new dbgcheck`, replace `src/main.rs` with the program below, set a
   breakpoint on the `println!` line, and debug it with `<LocalLeader>D`:

   ```rust
   use std::cell::RefCell;
   use std::collections::HashMap;
   use std::rc::Rc;
   use std::sync::Arc;

   #[derive(Debug)]
   enum Shape { Circle { r: f64 }, Square(u32) }

   fn main() {
       let s = String::from("hello");
       let st: &str = "world";
       let v = vec![1, 2, 3];
       let sl: &[i32] = &v[1..];
       let mut m = HashMap::new();
       m.insert("a", 1);
       m.insert("b", 2);
       let some: Option<String> = Some("x".into());
       let none: Option<String> = None;
       let ok: Result<i32, String> = Ok(7);
       let b = Box::new(42);
       let rc = Rc::new(RefCell::new(vec!["r"]));
       let arc = Arc::new(5u8);
       let shapes = vec![Shape::Circle { r: 1.5 }, Shape::Square(3)];
       let c = 'é';
       println!("{s} {st} {v:?} {sl:?} {m:?} {some:?} {none:?} {ok:?} {b} {rc:?} {arc} {shapes:?} {c}");
   }
   ```

3. In dap-ui's Scopes panel:

   | Variable | Working | Not working |
   |---|---|---|
   | `s` | `"hello"` | `vec`, `buf`, `ptr`, `cap`, `len` fields |
   | `v` | `size=3`, children `[0] 1, [1] 2, [2] 3` | `buf` and `len` fields, no elements |
   | `m` | `size=2`, with `"a"`/`"b"` entries | a hashbrown `table` with `ctrl`, `bucket_mask` and similar |
   | `some` / `none` | `Some("x")` / `None` | an enum with `$discr$`-style or `__0` fields |
   | `rc` | strong/weak counts with the inner `RefCell` → `Vec` | `ptr` → `RcInner` internals |

   Your own enums and `char` look fine either way, so they prove nothing.

4. In the dap REPL (`<Leader>dR`), `type category list` should show
   `Category: Rust (enabled)` (prefix with `/cmd ` if the REPL evaluates it as
   an expression).

5. If something is off, run `:lua require('dap').set_log_level('TRACE')`,
   debug again, then search `:DapShowLog` for `initCommands` and `error:`.

To confirm a toolchain would have hit the original bug, look for blank lines:

```sh
grep -n '^[[:space:]]*$' "$(rustc --print sysroot)/lib/rustlib/etc/lldb_commands"
```
