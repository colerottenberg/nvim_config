-- Debugging (nvim-dap + dap-ui + virtual text). Ported from the old
-- lua/plugins/debugging.lua. Python is wired through uv (see lua/dap_uv.lua).

-- ── Toolchain paths ──────────────────────────────────────────────────────
-- Only read when the corresponding adapter is actually used, so a missing
-- cross-toolchain never breaks local C/C++/Python debugging.
local EMBEDDED_GDB = vim.env.CROSS_GDB or "aarch64-linux-gnu-gdb"
local ESP_GDB = vim.env.ESP_GDB or "xtensa-esp32s3-elf-gdb"

require("dap_uv").setup()

-- Mason-managed adapter installs (codelldb etc.).
require("mason-nvim-dap").setup { ensure_installed = {}, automatic_installation = false, handlers = {} }

-- Inline variable values (virtual text) during a debug session.
require("nvim-dap-virtual-text").setup {
  enabled = false,
  enabled_commands = true,
  highlight_changed_variables = true,
  show_stop_reason = true,
  commented = false,
}

local dap = require "dap"
local dapui = require "dapui"
local utils = require "dap.utils"

-- Allow comments in .vscode/launch.json.
do
  local vscode = require "dap.ext.vscode"
  local orig = vscode.json_decode
  vscode.json_decode = function(str) return vim.json.decode(str, { luanil = { object = true } }) end
  if not pcall(vim.json.decode, "{}", { luanil = { object = true } }) then vscode.json_decode = orig end
end

-- ── Adapters ─────────────────────────────────────────────────────────────
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = { command = vim.fn.exepath "codelldb", args = { "--port", "${port}" } },
}
dap.adapters.gdb = {
  type = "executable",
  command = "gdb",
  args = { "--quiet", "--interpreter=dap" },
}
dap.adapters.gdb_embedded = {
  type = "executable",
  command = EMBEDDED_GDB,
  args = { "--quiet", "--interpreter=dap" },
}
dap.adapters.gdb_esp = {
  type = "executable",
  command = ESP_GDB,
  args = { "--quiet", "--interpreter=dap" },
}

-- ── Configurations ───────────────────────────────────────────────────────
local function pick_executable()
  return coroutine.create(function(dap_run_co)
    local path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
    coroutine.resume(dap_run_co, (path ~= "" and path) or dap.ABORT)
  end)
end

local cpp = {
  {
    name = "codelldb: launch local executable",
    type = "codelldb",
    request = "launch",
    program = pick_executable,
    cwd = "${workspaceFolder}",
    args = {},
    stopOnEntry = false,
  },
  {
    name = "codelldb: attach to running process",
    type = "codelldb",
    request = "attach",
    pid = utils.pick_process,
    cwd = "${workspaceFolder}",
  },
  {
    name = "gdb: launch local executable",
    type = "gdb",
    request = "launch",
    program = pick_executable,
    cwd = "${workspaceFolder}",
    args = {},
    stopAtBeginningOfMainSubprogram = false,
  },
  {
    name = "gdb: attach to running process",
    type = "gdb",
    request = "attach",
    pid = utils.pick_process,
    program = pick_executable,
    cwd = "${workspaceFolder}",
  },
  {
    name = "gdb: attach embedded Linux (gdbserver)",
    type = "gdb_embedded",
    request = "attach",
    program = function() return vim.fn.input("Local ELF (with symbols): ", vim.fn.getcwd() .. "/", "file") end,
    target = function() return vim.fn.input("gdbserver target (host:port): ", "192.168.1.50:3333") end,
    cwd = "${workspaceFolder}",
  },
  {
    name = "gdb: attach ESP32 (OpenOCD :3333)",
    type = "gdb_esp",
    request = "attach",
    program = function() return vim.fn.input("App ELF: ", vim.fn.getcwd() .. "/build/", "file") end,
    target = "localhost:3333",
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.cpp = vim.list_extend(dap.configurations.cpp or {}, cpp)
dap.configurations.c = vim.list_extend(dap.configurations.c or {}, cpp)

-- ── dap-ui ───────────────────────────────────────────────────────────────
dapui.setup()
dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

-- ── Completion in dap buffers (cmp-dap via blink.compat) ──────────────────
pcall(function()
  local blink = require "blink.cmp"
  for _, ft in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
    if blink.add_filetype_source then blink.add_filetype_source(ft, "dap") end
  end
end)

-- ── Keymaps ──────────────────────────────────────────────────────────────
local map = vim.keymap.set
map("n", "<Leader>db", function() dap.toggle_breakpoint() end, { desc = "DAP: toggle breakpoint" })
map(
  "n",
  "<Leader>dB",
  function() dap.set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
  { desc = "DAP: conditional breakpoint" }
)
map("n", "<Leader>dc", function() dap.continue() end, { desc = "DAP: continue / start" })
map("n", "<Leader>di", function() dap.step_into() end, { desc = "DAP: step into" })
map("n", "<Leader>do", function() dap.step_over() end, { desc = "DAP: step over" })
map("n", "<Leader>dO", function() dap.step_out() end, { desc = "DAP: step out" })
map("n", "<Leader>dr", function() dap.repl.toggle() end, { desc = "DAP: toggle REPL" })
map("n", "<Leader>dl", function() dap.run_last() end, { desc = "DAP: run last" })
map("n", "<Leader>dq", function() dap.terminate() end, { desc = "DAP: terminate" })
map("n", "<Leader>du", function() dapui.toggle() end, { desc = "DAP: toggle UI" })
map("n", "<Leader>uI", "<Cmd>DapVirtualTextToggle<CR>", { desc = "Toggle DAP inline values" })
map({ "n", "v" }, "<Leader>de", function() dapui.eval() end, { desc = "DAP: eval expression" })
map(
  "n",
  "<Leader>dF",
  function() require("dap_uv").run "file: current" end,
  { desc = "DAP: debug current Python file" }
)
map(
  "n",
  "<Leader>dt",
  function() require("dap_uv").run "pytest: current file" end,
  { desc = "DAP: pytest current file" }
)
map("n", "<Leader>dT", function() require("dap_uv").run "pytest: whole suite" end, { desc = "DAP: pytest suite" })
