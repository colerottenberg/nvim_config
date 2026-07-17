-- Debugging (nvim-dap + dap-ui + virtual text). Loads on its keymaps.
-- Python is wired through uv (see lua/dap_py.lua), but only set up when
-- editing Python: after/ftplugin/python.lua calls require("dap_py").setup()
-- so non-Python buffers never load/register it. See docs/dap-guide.md.
--
-- All user-facing prompts here go through `vim.ui.input`/`vim.ui.select`
-- (never `vim.fn.input`), so they're routed through dressing.nvim's UI.

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
    {
      "<Leader>db",
      function() require("dap").toggle_breakpoint() end,
      desc = "DAP: toggle breakpoint",
    },
    {
      "<Leader>dx",
      function() require("dap").clear_breakpoints() end,
      desc = "DAP: clear breakpoints",
    },
    {
      "<Leader>dB",
      function()
        vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
          if condition then require("dap").set_breakpoint(condition) end
        end)
      end,
      desc = "DAP: conditional breakpoint",
    },
    {
      "<Leader>dc",
      function() require("dap").continue() end,
      desc = "DAP: continue / start",
    },
    {
      "<Leader>di",
      function() require("dap").step_into() end,
      desc = "DAP: step into",
    },
    {
      "<Leader>do",
      function() require("dap").step_over() end,
      desc = "DAP: step over",
    },
    {
      "<Leader>dO",
      function() require("dap").step_out() end,
      desc = "DAP: step out",
    },
    {
      "<Leader>dr",
      function()
        local width = vim.o.columns
        local height = vim.o.lines
        local float_width = math.ceil(0.5 * width)
        local float_height = math.ceil(0.5 * height)

        require("dapui").float_element("repl", {
          position = "center",
          enter = true,
          title = "DAP Repl",
          width = float_width,
          height = float_height,
        })
      end,
      desc = "DAP: toggle REPL",
    },
    {
      "<Leader>dC",
      function()
        local width = vim.o.columns
        local height = vim.o.lines
        local float_width = math.ceil(0.7 * width)
        local float_height = math.ceil(0.7 * height)

        require("dapui").float_element("console", {
          position = "center",
          enter = true,
          title = "DAP Console",
          width = float_width,
          height = float_height,
        })
      end,
      desc = "DAP: toggle Console",
    },
    {
      "<Leader>dl",
      function() require("dap").run_last() end,
      desc = "DAP: run last",
    },
    {
      "<Leader>ds",
      function() require("dap").run_to_cursor() end,
      desc = "DAP: run to line",
    },
    {
      "<Leader>dq",
      function() require("dap").terminate() end,
      desc = "DAP: terminate",
    },
    {
      "<Leader>du",
      function() require("dapui").toggle() end,
      desc = "DAP: toggle UI",
    },
    {
      "<Leader>uI",
      "<Cmd>DapVirtualTextToggle<CR>",
      desc = "Toggle DAP inline values",
    },
    {
      "<Leader>de",
      function() require("dapui").eval() end,
      mode = { "n", "v" },
      desc = "DAP: eval expression",
    },
    -- Function keys (VS Code style). Terminals send Shift+F5/F11 either as
    -- <F17>/<F23> (legacy xterm) or <S-F5>/<S-F11> (kitty/CSI-u); bind both.
    { "<F5>",  function() require("dap").continue() end,          desc = "Debugger: continue / start" },
    { "<F6>",  function() require("dap").pause() end,             desc = "Debugger: pause" },
    { "<F9>",  function() require("dap").toggle_breakpoint() end, desc = "Debugger: toggle breakpoint" },
    { "<F10>", function() require("dap").step_over() end,         desc = "Debugger: step over" },
    { "<F11>", function() require("dap").step_into() end,         desc = "Debugger: step into" },
    {
      "<F17>",
      function() require("dap").terminate() end,
      desc = "Debugger: terminate (Shift+F5)",
    },
    { "<S-F5>",  function() require("dap").terminate() end, desc = "Debugger: terminate" },
    {
      "<F23>",
      function() require("dap").step_out() end,
      desc = "Debugger: step out (Shift+F11)",
    },
    { "<S-F11>", function() require("dap").step_out() end,  desc = "Debugger: step out" },
  },
  config = function()
    -- ── Toolchain paths ──────────────────────────────────────────────────
    -- Only read when the corresponding adapter is actually used, so a missing
    -- cross-toolchain never breaks local C/C++/Python debugging.
    local EMBEDDED_GDB = vim.env.CROSS_GDB or "aarch64-linux-gnu-gdb"
    local ESP_GDB = vim.env.ESP_GDB or "xtensa-esp32s3-elf-gdb"

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
      DapBreakpoint = { cp = 0xf111, hl = "DiagnosticError" },          -- circle
      DapBreakpointCondition = { cp = 0xf192, hl = "DiagnosticError" }, -- dot-circle
      DapBreakpointRejected = { cp = 0xf05e, hl = "DiagnosticError" },  -- ban
      DapLogPoint = { cp = 0xf0eb, hl = "DiagnosticInfo" },             -- lightbulb
      DapStopped = { cp = 0xf061, hl = "DiagnosticWarn" },              -- arrow-right
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
    -- Async text prompt via `vim.ui.input` (routed through dressing.nvim's
    -- UI, unlike `vim.fn.input`). Returns a coroutine, which is how nvim-dap
    -- expects config fields to resolve asynchronously -- see
    -- `:h dap-configuration`. `transform` maps the raw answer (never nil) to
    -- the field's final value.
    local function ui_input(opts, transform)
      transform = transform or function(answer) return answer end
      return coroutine.create(function(dap_run_co)
        vim.ui.input(opts, function(answer) coroutine.resume(dap_run_co, transform(answer or "")) end)
      end)
    end

    local function pick_executable()
      return ui_input(
        { prompt = "Path to executable: ", default = vim.fn.getcwd() .. "/build/", completion = "file" },
        function(path) return (path ~= "" and path) or dap.ABORT end
      )
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
        program = function()
          return ui_input { prompt = "Local ELF (with symbols): ", default = vim.fn.getcwd() .. "/", completion = "file" }
        end,
        target = function()
          return ui_input { prompt = "gdbserver target (host:port): ", default = "192.168.1.50:3333" }
        end,
        cwd = "${workspaceFolder}",
      },
      {
        name = "gdb: attach ESP32 (OpenOCD :3333)",
        type = "gdb_esp",
        request = "attach",
        program = function()
          return ui_input { prompt = "App ELF: ", default = vim.fn.getcwd() .. "/build/", completion = "file" }
        end,
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
