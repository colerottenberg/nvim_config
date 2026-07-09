-- lazy.nvim bootstrap and setup.
--
-- Plugin specs live in `lua/plugins/*.lua` and `lua/plugins/lang/*.lua`; each
-- file returns one or more lazy specs. The lockfile (lazy-lock.json) is
-- tracked in git for reproducible installs.

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Error cloning lazy.nvim:\n" .. out, "ErrorMsg" },
      { "\nPress any key to exit...", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {
  spec = {
    { import = "plugins" },
    { import = "plugins.lang" },
  },
  install = { colorscheme = { "catppuccin-macchiato", "habamax" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
}
