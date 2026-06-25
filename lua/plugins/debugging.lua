return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text", -- inline variable values during a session
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: toggle breakpoint" },
    {
      "<leader>dB",
      function() require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ") end,
      desc = "DAP: conditional breakpoint",
    },
    { "<leader>dc", function() require("dap").continue() end,          desc = "DAP: continue / start" },
    { "<leader>di", function() require("dap").step_into() end,         desc = "DAP: step into" },
    { "<leader>do", function() require("dap").step_over() end,         desc = "DAP: step over" },
    { "<leader>dO", function() require("dap").step_out() end,          desc = "DAP: step out" },
    { "<leader>dr", function() require("dap").repl.toggle() end,       desc = "DAP: toggle REPL" },
    -- Function keys (F5/F9/F10/F11 + shifted) live in lua/plugins/astrocore.lua
    -- `mappings` — they must be set there, not via lazy `keys`, or AstroNvim's
    -- own astrocore DAP mappings shadow them (and <S-F5>/<S-F11> need the F17/F23
    -- terminal keycodes). See docs/dap-guide.md.
    { "<leader>dl", function() require("dap").run_last() end,          desc = "DAP: run last" },
    { "<leader>dq", function() require("dap").terminate() end,         desc = "DAP: terminate" },
    { "<leader>du", function() require("dapui").toggle() end,          desc = "DAP: toggle UI" },
    { "<Leader>uI", "<Cmd>DapVirtualTextToggle<CR>",                   desc = "Toggle DAP inline values" },
    {
      "<leader>de",
      function() require("dapui").eval() end,
      mode = { "n", "v" },
      desc = "DAP: eval expression",
    },
    -- Python via uv (see lua/dap_uv.lua). Everything else is in the <leader>dc picker.
    {
      "<leader>dF",
      function() require("dap_uv").run "file: current" end,
      desc = "DAP: debug current Python file",
    },
    { "<leader>dt", function() require("dap_uv").run "pytest: current file" end, desc = "DAP: pytest current file" },
    { "<leader>dT", function() require("dap_uv").run "pytest: whole suite" end,  desc = "DAP: pytest suite" },
  },
  config = function()
    -- ── Toolchain paths ──────────────────────────────────────────────────
    -- Edit these (or export the env vars) to match your machine. They are only
    -- read when the corresponding adapter is actually used, so a missing
    -- cross-toolchain never breaks local C/C++/Python debugging.
    --
    --   EMBEDDED_GDB : the GDB that understands your target's architecture,
    --                  e.g. from a Yocto/Buildroot SDK ("aarch64-poky-linux-gdb")
    --                  or a multiarch host gdb. Requires GDB >= 14.1 (DAP).
    --   ESP_GDB      : the Espressif GDB for your chip family. The IDF toolchain
    --                  ships per-chip binaries (there is no generic
    --                  `xtensa-esp-elf-gdb` on PATH), so name the chip:
    --                  ESP32-S3: xtensa-esp32s3-elf-gdb
    --                  ESP32/S2: xtensa-esp32-elf-gdb / xtensa-esp32s2-elf-gdb
    --                  RISC-V (C3/C6/H2/P4): riscv32-esp-elf-gdb
    --                  Needs the IDF env active in the shell that launched nvim
    --                  (`. ~/esp/esp-idf/export.sh`), or set an absolute path.
    local EMBEDDED_GDB = vim.env.CROSS_GDB or "aarch64-linux-gnu-gdb"
    local ESP_GDB = vim.env.ESP_GDB or "xtensa-esp32s3-elf-gdb"

    require("dap_uv").setup()

    -- Inline variable values (virtual text) during a debug session.
    -- On by default; only renders while a session is live. Toggle with <Leader>uI.
    require("nvim-dap-virtual-text").setup {
      enabled = false,
      enabled_commands = true, -- :DapVirtualText{Enable,Disable,Toggle,ForceRefresh}
      highlight_changed_variables = true,
      show_stop_reason = true,
      commented = false, -- prefix values with the comment string, e.g. `# x = 3`
    }

    local dap = require "dap"
    local utils = require "dap.utils"

    -- ── Adapters ─────────────────────────────────────────────────────────

    -- codelldb (LLDB-based). Installed via Mason; used for native local C/C++.
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.exepath "codelldb",
        args = { "--port", "${port}" },
      },
    }

    -- Host GDB's native DAP interpreter (GDB >= 14.1). Used for local debugging
    -- and as the base for remote/cross targets via dedicated adapters below.
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--quiet", "--interpreter=dap" },
    }

    -- Cross GDB for an embedded Linux target reached over gdbserver.
    dap.adapters.gdb_embedded = {
      type = "executable",
      command = EMBEDDED_GDB,
      args = { "--quiet", "--interpreter=dap" },
    }

    -- Espressif GDB for ESP32, connecting to OpenOCD's gdbserver.
    dap.adapters.gdb_esp = {
      type = "executable",
      command = ESP_GDB,
      args = { "--quiet", "--interpreter=dap" },
    }

    -- ── Configurations ───────────────────────────────────────────────────
    -- All entries below appear in the `<leader>dc` picker for C/C++ buffers.

    local function pick_executable()
      return coroutine.create(function(dap_run_co)
        local path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
        coroutine.resume(dap_run_co, (path ~= "" and path) or dap.ABORT)
      end)
    end

    local cpp = {
      -- 1) Native local debugging with codelldb.
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

      -- 2) Local debugging with GDB's native DAP (GDB >= 14.1).
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

      -- 3) Remote "embedded" Linux target over gdbserver.
      --    On the device:  gdbserver :3333 /usr/bin/your_app    (or --attach PID)
      --    `program` is the LOCAL ELF (with symbols) matching what runs there.
      --    `target` is passed straight to GDB's `target remote`.
      {
        name = "gdb: attach embedded Linux (gdbserver)",
        type = "gdb_embedded",
        request = "attach",
        program = function() return vim.fn.input("Local ELF (with symbols): ", vim.fn.getcwd() .. "/", "file") end,
        target = function() return vim.fn.input("gdbserver target (host:port): ", "192.168.1.50:3333") end,
        cwd = "${workspaceFolder}",
      },

      -- 4) ESP32 over OpenOCD's gdbserver.
      --    Start OpenOCD first (separate terminal or an Overseer task), e.g.:
      --      openocd -f board/esp32-wrover-kit-3.3v.cfg
      --    or, inside an ESP-IDF project:
      --      idf.py openocd
      --    OpenOCD exposes the GDB server on localhost:3333.
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
    -- Drop this block if your config already wires dap-ui elsewhere.
    local dapui = require "dapui"
    dapui.setup()
    dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui"] = function() dapui.close() end
  end,
}
