return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    table.insert(opts.servers, "buck2")

    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      buck2 = {
        cmd = {
          "buck2",
          "lsp",
        },
        filetypes = { "bzl", "starlark" },
        root_dir = require("lspconfig.util").root_pattern ".buckconfig",
      },
    })
  end,
}
