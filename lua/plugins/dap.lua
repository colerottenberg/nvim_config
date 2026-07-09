-- Debugging (nvim-dap + dap-ui + virtual text). Loads on its keymaps.
-- Python is wired through uv (see lua/dap_uv.lua); see docs/dap-guide.md.

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
    "rcarriga/cmp-dap",
    "saghen/blink.compat",
  },
  keys = {
    { "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
    {
      "<Leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
      desc = "DAP: conditional breakpoint",
    },
    { "<Leader>dc", function() require("dap").continue() end, desc = "DAP: continue / start" },
    { "<Leader>di", function() require("dap").step_into() end, desc = "DAP: step into" },
    { "<Leader>do", function() require("dap").step_over() end, desc = "DAP: step over" },
    { "<Leader>dO", function() require("dap").step_out() end, desc = "DAP: step out" },
    { "<Leader>dr", function() require("dap").repl.toggle() end, desc = "DAP: toggle REPL" },
    { "<Leader>dl", function() require("dap").run_last() end, desc = "DAP: run last" },
    { "<Leader>dq", function() require("dap").terminate() end, desc = "DAP: terminate" },
    { "<Leader>du", function() require("dapui").toggle() end, desc = "DAP: toggle UI" },
    { "<Leader>uI", "<Cmd>DapVirtualTextToggle<CR>", desc = "Toggle DAP inline values" },
    { "<Leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "DAP: eval expression" },
    { "<Leader>dF", function() require("dap_uv").run "file: current" end, desc = "DAP: debug current Python file" },
    { "<Leader>dt", function() require("dap_uv").run "pytest: current file" end, desc = "DAP: pytest current file" },
    { "<Leader>dT", function() require("dap_uv").run "pytest: whole suite" end, desc = "DAP: pytest suite" },
    -- Function keys (VS Code style). Terminals send Shift+F5/F11 either as
    -- <F17>/<F23> (legacy xterm) or <S-F5>/<S-F11> (kitty/CSI-u); bind both.
    { "<F5>", function() require("dap").continue() end, desc = "Debugger: continue / start" },
    { "<F6>", function() require("dap").pause() end, desc = "Debugger: pause" },
    { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debugger: toggle breakpoint" },
    { "<F10>", function() require("dap").step_over() end, desc = "Debugger: step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "Debugger: step into" },
    { "<F17>", function() require("dap").terminate() end, desc = "Debugger: terminate (Shift+F5)" },
    { "<S-F5>", function() require("dap").terminate() end, desc = "Debugger: terminate" },
    { "<F23>", function() require("dap").step_out() end, desc = "Debugger: step out (Shift+F11)" },
    { "<S-F11>", function() require("dap").step_out() end, desc = "Debugger: step out" },
  },
  config = function()
    -- ── Toolchain paths ──────────────────────────────────────────────────
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

    -- Breakpoint / stopped signs (Nerd Font). Without these, nvim-dap falls
    -- back to plain "B"/"●" text in the sign column. Icons are built from
    -- codepoints (Font Awesome range, present in every Nerd Font) via nr2char
    -- so the glyphs don't depend on this file's byte encoding.
    local dap_signs = {
      DapBreakpoint = { cp = 0xf111, hl = "DiagnosticError" }, -- circle
      DapBreakpointCondition = { cp = 0xf192, hl = "DiagnosticError" }, -- dot-circle
      DapBreakpointRejected = { cp = 0xf05e, hl = "DiagnosticError" }, -- ban
      DapLogPoint = { cp = 0xf0eb, hl = "DiagnosticInfo" }, -- lightbulb
      DapStopped = { cp = 0xf061, hl = "DiagnosticWarn" }, -- arrow-right
    }
    for name, o in pairs(dap_signs) do
      vim.fn.sign_define(name, {
        text = vim.fn.nr2char(o.cp),
        texthl = o.hl,
        linehl = name == "DapStopped" and "Visual" or nil,
        numhl = name == "DapStopped" and o.hl or nil,
      })
    end

    -- Allow comments in .vscode/launch.json.
    do
      local vscode = require "dap.ext.vscode"
      local orig = vscode.json_decode
      vscode.json_decode = function(str) return vim.json.decode(str, { luanil = { object = true } }) end
      if not pcall(vim.json.decode, "{}", { luanil = { object = true } }) then vscode.json_decode = orig end
    end

    -- ── Adapters ─────────────────────────────────────────────────────────
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

    -- ── Configurations ───────────────────────────────────────────────────
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

    -- ── dap-ui ───────────────────────────────────────────────────────────
    dapui.setup()
    dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

    -- ── Completion in dap buffers (cmp-dap via blink.compat) ─────────────
    pcall(function()
      local blink = require "blink.cmp"
      for _, ft in ipairs { "dap-repl", "dapui_watches", "dapui_hover" } do
        if blink.add_filetype_source then blink.add_filetype_source(ft, "dap") end
      end
    end)
  end,
}
