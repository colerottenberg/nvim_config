-- Debugging (nvim-dap + dap-ui + virtual text). Loads on its keymaps.
-- Python is wired through uv in plugins/lang/python.lua, which registers its
-- adapter/configs on `User DapConfigured` (fired at the end of config below)
-- and owns the python keymaps.
--
-- All user-facing prompts here go through `vim.ui.input`/`vim.ui.select`
-- (never `vim.fn.input`), so they're routed through dressing.nvim's UI.

---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
    'jay-babu/mason-nvim-dap.nvim',
    'rcarriga/cmp-dap',
    'saghen/blink.compat',
    'Weissle/persistent-breakpoints.nvim',
    'folke/snacks.nvim',
  },
  keys = {
    {
      '<Leader>fB',
      function()
        local items = {}

        for bufnr, breakpoints in pairs(require('dap.breakpoints').get()) do
          local file = vim.api.nvim_buf_get_name(bufnr)
          local display_file = file ~= '' and vim.fn.fnamemodify(file, ':~:.') or '[No Name]'

          for _, breakpoint in ipairs(breakpoints) do
            local details = {}

            if breakpoint.condition then
              table.insert(details, 'condition: ' .. breakpoint.condition)
            end
            if breakpoint.hitCondition then
              table.insert(details, 'hit: ' .. breakpoint.hitCondition)
            end
            if breakpoint.logMessage then
              table.insert(details, 'log: ' .. breakpoint.logMessage)
            end
            if breakpoint.state and breakpoint.state.verified == false then
              table.insert(details, 'unverified')
            end

            local suffix = #details > 0 and ' [' .. table.concat(details, ', ') .. ']' or ''
            local icon = '●'
            local icon_hl = 'DiagnosticError'

            if breakpoint.condition then
              icon = ''
              icon_hl = 'DiagnosticWarn'
            elseif breakpoint.logMessage then
              icon = ''
              icon_hl = 'DiagnosticInfo'
            end

            if breakpoint.state and breakpoint.state.verified == false then
              icon = ''
              icon_hl = 'DiagnosticError'
            end

            table.insert(items, {
              text = string.format('%s:%d%s', display_file, breakpoint.line, suffix),
              icon = icon,
              icon_hl = icon_hl,
              file = file,
              pos = { breakpoint.line, 1 },
              buf = bufnr,
            })
          end
        end

        if #items == 0 then
          vim.notify('No breakpoints set', vim.log.levels.INFO)
          return
        end

        local function selected_items(picker)
          return picker:selected({ fallback = true })
        end

        local function with_breakpoint(item, fn)
          vim.api.nvim_set_current_buf(item.buf)
          vim.api.nvim_win_set_cursor(0, item.pos)
          fn()
        end

        local function delete_breakpoint(picker)
          local selected = selected_items(picker)
          picker:close()
          for _, item in ipairs(selected) do
            with_breakpoint(item, function()
              require('persistent-breakpoints.api').toggle_breakpoint()
            end)
          end
        end

        local function edit_breakpoint(picker)
          local item = selected_items(picker)[1]
          if item then
            picker:close()
            with_breakpoint(item, function()
              require('persistent-breakpoints.api').set_conditional_breakpoint()
            end)
          end
        end

        local function clear_breakpoints(picker)
          picker:close()
          require('persistent-breakpoints.api').clear_all_breakpoints()
        end

        local function yank_breakpoint(picker)
          local item = selected_items(picker)[1]
          if item then
            vim.fn.setreg('+', string.format('%s:%d', item.file, item.pos[1]))
            vim.notify('Copied breakpoint location', vim.log.levels.INFO)
          end
        end

        local function yank_breakpoint_details(picker)
          local item = selected_items(picker)[1]
          if item then
            vim.fn.setreg('+', item.text)
            vim.notify('Copied breakpoint details', vim.log.levels.INFO)
          end
        end

        require('snacks').picker.pick({
          title = 'DAP Breakpoints',
          items = items,
          format = function(item)
            return {
              { item.icon .. ' ', item.icon_hl or 'SnacksPickerIcon' },
              { item.text, item.text_hl },
            }
          end,
          preview = 'file',
          actions = {
            delete_breakpoint = delete_breakpoint,
            edit_breakpoint = edit_breakpoint,
            clear_breakpoints = clear_breakpoints,
            yank_breakpoint = yank_breakpoint,
            yank_breakpoint_details = yank_breakpoint_details,
          },
          win = {
            input = {
              keys = {
                ['x'] = { 'delete_breakpoint', mode = { 'n' }, desc = 'Delete breakpoint' },
                ['e'] = { 'edit_breakpoint', mode = { 'n' }, desc = 'Edit condition' },
                ['X'] = { 'clear_breakpoints', mode = { 'n' }, desc = 'Clear all breakpoints' },
                ['y'] = { 'yank_breakpoint', mode = { 'n' }, desc = 'Copy location' },
                ['Y'] = { 'yank_breakpoint_details', mode = { 'n' }, desc = 'Copy details' },
                ['s'] = { 'edit_split', mode = { 'n' }, desc = 'Open in split' },
                ['v'] = { 'edit_vsplit', mode = { 'n' }, desc = 'Open in vertical split' },
                ['t'] = { 'edit_tab', mode = { 'n' }, desc = 'Open in tab' },
              },
            },
            list = {
              keys = {
                ['x'] = { 'delete_breakpoint', mode = { 'n' }, desc = 'Delete breakpoint' },
                ['e'] = { 'edit_breakpoint', mode = { 'n' }, desc = 'Edit condition' },
                ['X'] = { 'clear_breakpoints', mode = { 'n' }, desc = 'Clear all breakpoints' },
                ['y'] = { 'yank_breakpoint', mode = { 'n' }, desc = 'Copy location' },
                ['Y'] = { 'yank_breakpoint_details', mode = { 'n' }, desc = 'Copy details' },
                ['s'] = { 'edit_split', mode = { 'n' }, desc = 'Open in split' },
                ['v'] = { 'edit_vsplit', mode = { 'n' }, desc = 'Open in vertical split' },
                ['t'] = { 'edit_tab', mode = { 'n' }, desc = 'Open in tab' },
              },
            },
          },
        })
      end,
      desc = 'Find Breakpoints',
    },
    {
      '<Leader>d<CR>',
      function()
        require('dap').focus_frame()
      end,
      desc = 'Focus Frame',
    },
    {
      '<Leader>db',
      function()
        require('persistent-breakpoints.api').toggle_breakpoint()
      end,
      desc = 'toggle breakpoint',
    },
    {
      '<Leader>dx',
      function()
        require('persistent-breakpoints.api').clear_all_breakpoints()
      end,
      desc = 'clear breakpoints',
    },
    {
      '<Leader>dB',
      function()
        require('persistent-breakpoints.api').set_conditional_breakpoint()
      end,
      desc = 'conditional breakpoint',
    },
    {
      '<Leader>dL',
      function()
        require('persistent-breakpoints.api').set_log_point()
      end,
      desc = 'log breakpoint',
    },
    {
      '<Leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'continue / start',
    },
    {
      '<Leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'step into',
    },
    {
      '<Leader>do',
      function()
        require('dap').step_over()
      end,
      desc = 'step over',
    },
    {
      '<Leader>dO',
      function()
        require('dap').step_out()
      end,
      desc = 'step out',
    },

    {
      '<Leader>dr',
      function()
        require('dap').restart()
      end,
      desc = 'restart',
    },
    {
      '<Leader>df',
      function()
        require('dap').restart_frame()
      end,
      desc = 'restart frame',
    },
    {
      '<Leader>dR',
      function()
        local width = vim.o.columns
        local height = vim.o.lines
        local float_width = math.ceil(0.5 * width)
        local float_height = math.ceil(0.5 * height)

        require('dapui').float_element('repl', {
          position = 'center',
          enter = true,
          title = 'DAP Repl',
          width = float_width,
          height = float_height,
        })
      end,
      desc = 'toggle REPL',
    },
    {
      '<Leader>dC',
      function()
        local width = vim.o.columns
        local height = vim.o.lines
        local float_width = math.ceil(0.7 * width)
        local float_height = math.ceil(0.7 * height)

        require('dapui').float_element('console', {
          position = 'center',
          enter = true,
          title = 'DAP Console',
          width = float_width,
          height = float_height,
        })
      end,
      desc = 'toggle Console',
    },
    {
      '<Leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'run last',
    },
    {
      '<Leader>ds',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'run to line',
    },
    {
      '<Leader>dq',
      function()
        require('dap').terminate()
      end,
      desc = 'terminate',
    },
    {
      '<Leader>du',
      function()
        require('dapui').toggle()
      end,
      desc = 'toggle UI',
    },
    {
      '<Leader>dD',
      function()
        local dap = require('dap')
        local dapui = require('dapui')
        dap.listeners.after.event_initialized['dapui'] = nil
        dap.listeners.before.event_terminated['dapui'] = nil
        dap.listeners.before.event_exited['dapui'] = nil
        dapui.close()
      end,
      desc = 'Disable UI',
    },
    {
      '<Leader>de',
      function()
        require('dapui').eval()
      end,
      mode = { 'n', 'v' },
      desc = 'eval expression',
    },
    -- Function keys (VS Code style). Terminals send Shift+F5/F11 either as
    -- <F17>/<F23> (legacy xterm) or <S-F5>/<S-F11> (kitty/CSI-u); bind both.
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debugger: continue / start',
    },
    {
      '<F6>',
      function()
        require('dap').pause()
      end,
      desc = 'Debugger: pause',
    },
    {
      '<F9>',
      function()
        require('persistent-breakpoints.api').toggle_breakpoint()
      end,
      desc = 'Debugger: toggle breakpoint',
    },
    {
      '<F10>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debugger: step over',
    },
    {
      '<F11>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debugger: step into',
    },
    {
      '<F17>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debugger: terminate (Shift+F5)',
    },
    {
      '<S-F5>',
      function()
        require('dap').terminate()
      end,
      desc = 'Debugger: terminate',
    },
    {
      '<F23>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debugger: step out (Shift+F11)',
    },
    {
      '<S-F11>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debugger: step out',
    },
  },
  config = function()
    -- ── Toolchain paths ──────────────────────────────────────────────────
    -- Only read when the corresponding adapter is actually used, so a missing
    -- cross-toolchain never breaks local C/C++/Python debugging.
    local EMBEDDED_GDB = vim.env.CROSS_GDB or 'aarch64-linux-gnu-gdb'
    local ESP_GDB = vim.env.ESP_GDB or 'xtensa-esp32s3-elf-gdb'

    -- Mason-managed adapter installs.
    require('mason-nvim-dap').setup({
      ensure_installed = { 'codelldb', 'debugpy' },
      automatic_installation = false,
      handlers = {},
    })

    require('persistent-breakpoints').setup({

      save_dir = vim.fn.stdpath('data') .. '/nvim_checkpoints',
      -- when to load the breakpoints? "BufReadPost" is recommanded.
      load_breakpoints_event = 'BufReadPost',
      -- record the performance of different function. run :lua require('persistent-breakpoints.api').print_perf_data() to see the result.
      perf_record = false,
      -- perform callback when loading a persisted breakpoint
      --- @param opts DAPBreakpointOptions options used to create the breakpoint ({condition, logMessage, hitCondition})
      --- @param buf_id integer the buffer the breakpoint was set on
      --- @param line integer the line the breakpoint was set on
      on_load_breakpoint = nil,
      -- set this to true if the breakpoints are not loaded when you are using a session-like plugin.
      always_reload = false,
    })

    -- Inline variable values (virtual text) during a debug session.
    local dap_vt = require('nvim-dap-virtual-text')
    dap_vt.setup({
      enabled = false,
      enabled_commands = true,
      highlight_changed_variables = true,
      show_stop_reason = true,
      commented = false,
    })

    local dap = require('dap')
    local dapui = require('dapui')
    local utils = require('dap.utils')

    -- Breakpoint / stopped signs (Nerd Font). Without these, nvim-dap falls
    -- back to plain "B"/"●" text in the sign column. Icons are built from
    -- codepoints (Font Awesome range, present in every Nerd Font) via nr2char
    -- so the glyphs don't depend on this file's byte encoding.
    local dap_signs = {
      DapBreakpoint = { cp = 0xf111, hl = 'DiagnosticError' }, -- circle
      DapBreakpointCondition = { cp = 0xf192, hl = 'DiagnosticError' }, -- dot-circle
      DapBreakpointRejected = { cp = 0xf05e, hl = 'DiagnosticError' }, -- ban
      DapLogPoint = { cp = 0xf0eb, hl = 'DiagnosticInfo' }, -- lightbulb
      DapStopped = { cp = 0xf061, hl = 'DiagnosticWarn' }, -- arrow-right
    }
    for name, o in pairs(dap_signs) do
      vim.fn.sign_define(name, {
        text = vim.fn.nr2char(o.cp),
        texthl = o.hl,
        linehl = name == 'DapStopped' and 'Visual' or nil,
        numhl = name == 'DapStopped' and o.hl or nil,
      })
    end

    -- Allow comments in .vscode/launch.json.
    do
      local vscode = require('dap.ext.vscode')
      local orig = vscode.json_decode
      vscode.json_decode = function(str)
        return vim.json.decode(str, { luanil = { object = true } })
      end
      if not pcall(vim.json.decode, '{}', { luanil = { object = true } }) then
        vscode.json_decode = orig
      end
    end

    -- ── Adapters ─────────────────────────────────────────────────────────
    dap.adapters.gdb = {
      type = 'executable',
      command = 'gdb',
      args = { '--quiet', '--interpreter=dap' },
    }
    dap.adapters.gdb_embedded = {
      type = 'executable',
      command = EMBEDDED_GDB,
      args = { '--quiet', '--interpreter=dap' },
    }
    dap.adapters.gdb_esp = {
      type = 'executable',
      command = ESP_GDB,
      args = { '--quiet', '--interpreter=dap' },
    }

    -- ── Configurations ───────────────────────────────────────────────────
    -- Async text prompt via `vim.ui.input` (routed through dressing.nvim's
    -- UI, unlike `vim.fn.input`). Returns a coroutine, which is how nvim-dap
    -- expects config fields to resolve asynchronously -- see
    -- `:h dap-configuration`. `transform` maps the raw answer (never nil) to
    -- the field's final value.
    local function ui_input(opts, transform)
      transform = transform or function(answer)
        return answer
      end
      return coroutine.create(function(dap_run_co)
        vim.ui.input(opts, function(answer)
          coroutine.resume(dap_run_co, transform(answer or ''))
        end)
      end)
    end

    local function pick_executable()
      return ui_input(
        { prompt = 'Path to executable: ', default = vim.fn.getcwd() .. '/build/', completion = 'file' },
        function(path)
          return (path ~= '' and path) or dap.ABORT
        end
      )
    end

    local cpp = {
      {
        name = 'codelldb: launch local executable',
        type = 'codelldb',
        request = 'launch',
        program = pick_executable,
        cwd = '${workspaceFolder}',
        args = {},
        stopOnEntry = false,
      },
      {
        name = 'codelldb: attach to running process',
        type = 'codelldb',
        request = 'attach',
        pid = utils.pick_process,
        cwd = '${workspaceFolder}',
      },
      {
        name = 'gdb: launch local executable',
        type = 'gdb',
        request = 'launch',
        program = pick_executable,
        cwd = '${workspaceFolder}',
        args = {},
        stopAtBeginningOfMainSubprogram = false,
      },
      {
        name = 'gdb: attach to running process',
        type = 'gdb',
        request = 'attach',
        pid = utils.pick_process,
        program = pick_executable,
        cwd = '${workspaceFolder}',
      },
      {
        name = 'gdb: attach embedded Linux (gdbserver)',
        type = 'gdb_embedded',
        request = 'attach',
        program = function()
          return ui_input({
            prompt = 'Local ELF (with symbols): ',
            default = vim.fn.getcwd() .. '/',
            completion = 'file',
          })
        end,
        target = function()
          return ui_input({ prompt = 'gdbserver target (host:port): ', default = '192.168.1.50:3333' })
        end,
        cwd = '${workspaceFolder}',
      },
      {
        name = 'gdb: attach ESP32 (OpenOCD :3333)',
        type = 'gdb_esp',
        request = 'attach',
        program = function()
          return ui_input({ prompt = 'App ELF: ', default = vim.fn.getcwd() .. '/build/', completion = 'file' })
        end,
        target = 'localhost:3333',
        cwd = '${workspaceFolder}',
      },
    }

    dap.configurations.cpp = vim.list_extend(dap.configurations.cpp or {}, cpp)
    dap.configurations.c = vim.list_extend(dap.configurations.c or {}, cpp)

    -- ── dap-ui ───────────────────────────────────────────────────────────
    dapui.setup()
    dap.listeners.after.event_initialized['dapui'] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated['dapui'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui'] = function()
      dapui.close()
    end

    local dapui_open = true

    -- Adding Snacks Toggle for DAP UI
    local snacks = require('snacks')
    local dapui_toggle = snacks.toggle.new({
      id = 'dapui',
      name = 'DAP UI',
      get = function()
        return dapui_open
      end,
      set = function(state)
        if state then
          dap.listeners.after.event_initialized['dapui'] = function()
            dapui.open()
          end
        else
          dap.listeners.after.event_initialized['dapui'] = nil
        end
      end,
    })
    dapui_toggle:map('<Leader>uD')

    local dap_virtual_text_toggle = snacks.toggle.new({
      name = 'DAP virtual text',
      get = function()
        return dap_vt.is_enabled()
      end,
      set = function(state)
        if state then
          dap_vt.enable()
        else
          dap_vt.disable()
        end
      end,
    })
    dap_virtual_text_toggle:map('<leader>dI')

    -- ── Completion in dap buffers (cmp-dap via blink.compat) ─────────────
    pcall(function()
      local blink = require('blink.cmp')
      for _, ft in ipairs({ 'dap-repl', 'dapui_watches', 'dapui_hover' }) do
        if blink.add_filetype_source then
          blink.add_filetype_source(ft, 'dap')
        end
      end
    end)

    -- Language specs (plugins/lang/*.lua) hook adapters/configs in here.
    -- Synchronous, unlike lazy's scheduled `User LazyLoad`, so the first
    -- `<Leader>dc` already sees them; and it runs after mason-nvim-dap's
    -- default handlers, so language adapters take precedence.
    vim.api.nvim_exec_autocmds('User', { pattern = 'DapConfigured', modeline = false })
  end,
}
