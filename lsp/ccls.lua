return {
  cmd = { "ccls" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { "compile_commands.json", ".ccls", ".ccls-root", ".git" },
  init_options = {
    cache = {
      directory = vim.fn.expand("~/.cache/ccls"),
    },
    clang = {
      excludeArgs = { "-frounding-math" },
    },
  },
}
