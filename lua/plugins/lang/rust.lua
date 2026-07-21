-- Rust: rustaceanvim (owns rust_analyzer; loads on ft=rust) + crates.nvim.
-- Buffer-local Rust keymaps live in after/ftplugin/rust.lua.

return {
  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    ft = "rust",
    init = function()
      -- rustaceanvim reads this global; must exist before the rust ftplugin runs.
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              files = { exclude = { ".direnv", ".git", "target" } },
              check = { command = "clippy", extraArgs = { "--no-deps" } },
            },
          },
        },
        dap = { load_rust_types = true },
        tools = { enable_clippy = false },
      }
    end,
  },

  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
}
