-- Task runner.

local has_toggleterm = pcall(require, "toggleterm")

require("overseer").setup {
  strategy = has_toggleterm and "toggleterm" or "terminal",
  task_list = {
    bindings = {
      ["<C-l>"] = false,
      ["<C-h>"] = false,
      ["<C-k>"] = false,
      ["<C-j>"] = false,
      ["q"] = "<Cmd>close<CR>",
      ["K"] = "IncreaseDetail",
      ["J"] = "DecreaseDetail",
      ["<C-p>"] = "ScrollOutputUp",
      ["<C-n>"] = "ScrollOutputDown",
    },
  },
}

local map = vim.keymap.set
map("n", "<Leader>Mt", "<Cmd>OverseerToggle<CR>", { desc = "Toggle Overseer" })
map("n", "<Leader>Mc", "<Cmd>OverseerShell<CR>", { desc = "Run command" })
map("n", "<Leader>Mr", "<Cmd>OverseerRun<CR>", { desc = "Run task" })
map("n", "<Leader>Ma", "<Cmd>OverseerTaskAction<CR>", { desc = "Task action" })
map("n", "<Leader>Mi", function() vim.cmd.checkhealth "overseer" end, { desc = "Overseer info" })
