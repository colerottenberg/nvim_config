return {
  "mfussenegger/nvim-dap-python",
  config = function()
    local dap = require "dap-python"
    dap.setup "uv"
    dap.test_runner = "pytest"
  end,
}
