return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    table.insert(opts.servers, "pyrefly")

    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      pyrefly = {
        cmd = {
          "uvx",
          "pyrefly",
          "lsp",
        },
        filetypes = { "python" },
        root_dir = require("lspconfig.util").root_pattern "pyproject.toml",
      },
    })
  end,
}
