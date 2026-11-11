---@type LazySpec
return {
  'sudo-tee/opencode.nvim',
  ---@type OpencodeConfig
  opts = {
    ---@type OpencodeServerConfig
    server = {
      auto_kill = false,
    },
    preferred_picker = 'snacks',
    preferred_completion = 'blink',
    default_mode = 'build',
    keymap = {
      session_picker = {
        rename_session = { '<C-r>', mode = { 'i', 'n' } },
        delete_session = { '<C-d>', mode = { 'i', 'n' } },
        new_session = { '<C-n>', mode = { 'i', 'n' } },
        fork_session = { '<C-f>', mode = { 'i', 'n' } },
        open_in_tab = { '<C-t>', mode = { 'i', 'n' } },
        toggle_scope = { '<C-g>', mode = { 'i', 'n' } },
      },
      input_window = {
        ['<leader>om'] = { 'switch_mode' }, -- Switch between modes (build/plan)
        ['<leader>or'] = { 'cycle_variant' }, -- Switch between modes (build/plan)
      },
    },
    ui = {
      completion = {
        file_sources = {
          preferred_cli_tool = 'rg',
        },
      },
      input = {
        min_height = 0.30,
        max_height = 0.40,
        auto_hide = false,
      },
      icons = {
        preset = 'nerdfonts',
      },
    },
    context = {
      enabled = true,
      diagnostics = {
        enabled = false,
        info = true,
        only_closest = false,
      },
      git_diff = {
        enabled = true,
      },
      current_file = {
        enabled = false,
        show_full_path = true,
      },
    },
  },
  ---@param _ LazyPlugin
  ---@param opts OpencodeConfig
  config = function(_, opts)
    local configured_port = vim.env.OPENCODE_PORT
    local port = configured_port == nil and 40900 or tonumber(configured_port)

    if not port or port < 1 or port > 65535 or port % 1 ~= 0 then
      vim.notify_once(('Invalid OPENCODE_PORT: %s'):format(configured_port), vim.log.levels.ERROR)
      return
    end

    opts.server.port = port
    require('opencode').setup(opts)

    local function ai_commit_message_with_context()
      local Popup = require('nui.popup')

      local popup = Popup({
        enter = true,
        focusable = true,
        border = {
          style = 'rounded',
          text = { top = ' Additional commit context ', top_align = 'center' },
        },
        position = '50%',
        size = { width = '80%', height = '40%' },
        buf_options = {
          buftype = 'nofile',
          bufhidden = 'wipe',
          filetype = 'markdown',
          swapfile = false,
        },
        win_options = {
          cursorline = true,
          number = true,
          relativenumber = false,
          signcolumn = 'no',
          wrap = true,
          linebreak = true,
        },
      })

      local finished = false
      local function close()
        if not finished then
          finished = true
          popup:unmount()
        end
      end

      local function submit()
        if finished then
          return
        end

        local context = vim.trim(table.concat(vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false), '\n'))
        close()
        if context ~= '' then
          require('opencode.api').quick_chat(
            ('Generate a conventional commit message from #git_diff. Additional context:\n%s'):format(context)
          )
        end
      end

      popup:map('i', '<C-s>', submit, { noremap = true })
      popup:map('n', '<C-s>', submit, { noremap = true })
      popup:map('n', '<CR>', submit, { noremap = true })
      popup:map('i', '<C-c>', function()
        vim.cmd.stopinsert()
      end, { noremap = true })
      popup:map('n', '<C-c>', close, { noremap = true })
      popup:mount()
      vim.cmd.startinsert()
    end

    vim.api.nvim_create_user_command('AICommitMessage', function()
      require('opencode.api').quick_chat('Generate a conventional commit message from #git_diff')
    end, { desc = 'Generate a commit message on the current line' })

    vim.api.nvim_create_user_command('AICommitMessageContext', ai_commit_message_with_context, {
      desc = 'Generate a commit message with additional context',
    })

    vim.api.nvim_create_user_command('AIAnnotate', function(opts)
      require('opencode.api').quick_chat('Add type annotations and code comments', {
        start = opts.line1,
        stop = opts.line2,
      })
    end, { range = true, desc = 'Annotate the selected lines' })
    local snacks = require('snacks')
    snacks.keymap.set('n', '<localleader>c', function()
      require('opencode.api').quick_chat('Generate a conventional commit message from #git_diff')
    end, { desc = 'Generate a commit message on the current line', ft = 'gitcommit' })
    snacks.keymap.set('n', '<localleader>C', ai_commit_message_with_context, {
      desc = 'Generate a commit message with additional context',
      ft = 'gitcommit',
    })
  end,
  dependencies = {
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'markdown', 'opencode_output' },
      },
      ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
    },
    'saghen/blink.cmp',
    'folke/snacks.nvim',
    'MunifTanjim/nui.nvim',
  },
}
