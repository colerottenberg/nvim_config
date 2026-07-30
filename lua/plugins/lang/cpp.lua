-- C / C++ / CUDA: clangd config + clangd_extensions + cmake-tools.
-- Buffer-local symbol keymaps live in after/ftplugin/cpp.lua.

return {
  {
    'Civitasv/cmake-tools.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },
}
