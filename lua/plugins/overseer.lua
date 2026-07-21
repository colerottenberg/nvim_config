-- Task runner.

return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerOpen", "OverseerClose", "OverseerToggle", "OverseerShell", "OverseerRun", "OverseerTaskAction" },
  keys = {
    { "<Leader>mt", "<Cmd>OverseerToggle<CR>", desc = "Toggle Overseer" },
    { "<Leader>mc", "<Cmd>OverseerShell<CR>", desc = "Run command" },
    { "<Leader>mr", "<Cmd>OverseerRun<CR>", desc = "Run task" },
    { "<Leader>M", "<Cmd>OverseerRun<CR>", desc = "Run task" },
    { "<Leader>ma", "<Cmd>OverseerTaskAction<CR>", desc = "Task action" },
    { "<Leader>mi", function() vim.cmd.checkhealth "overseer" end, desc = "Overseer info" },
  },
  opts = function()
    return {
      strategy = pcall(require, "toggleterm") and "toggleterm" or "terminal",
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
  end,
}
