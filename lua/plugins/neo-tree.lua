-- File explorer. Ported from AstroNvim's neo-tree defaults, plus the custom
-- terminal / find-in-dir integrations.

local git_available = vim.fn.executable('git') == 1

local sources = { 'filesystem', 'buffers' }
local selector_sources = {
  { source = 'filesystem', display_name = '󰉓 File' },
  { source = 'buffers', display_name = '󰈚 Bufs' },
}
if git_available then
  table.insert(sources, 'git_status')
  table.insert(selector_sources, { source = 'git_status', display_name = '󰊢 Git' })
end
table.insert(selector_sources, { source = 'diagnostics', display_name = '󰒡 Diagnostic' })

return {
  'nvim-neo-tree/neo-tree.nvim',
  cmd = 'Neotree',
  cond = not vim.g.vscode,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    's1n7ax/nvim-window-picker',
  },
  keys = {
    { '<Leader>e', '<Cmd>Neotree toggle<CR>', desc = 'Toggle Explorer' },
    {
      '<Leader>o',
      function()
        if vim.bo.filetype == 'neo-tree' then
          vim.cmd.wincmd('p')
        else
          vim.cmd.Neotree('focus')
        end
      end,
      desc = 'Toggle Explorer Focus',
    },
  },
  opts = {
    enable_git_status = git_available,
    auto_clean_after_session_restore = true,
    close_if_last_window = true,
    sources = sources,
    source_selector = {
      winbar = true,
      content_layout = 'center',
      sources = selector_sources,
    },
    default_component_configs = {
      indent = { padding = 0, expander_collapsed = '', expander_expanded = '' },
      icon = {
        folder_closed = '󰉋',
        folder_open = '󰷏',
        folder_empty = '󰉖',
        folder_empty_open = '󰉖',
        default = '󰈔',
      },
      modified = { symbol = '' },
      git_status = {
        symbols = {
          added = '',
          deleted = '',
          modified = '',
          renamed = '󰁕',
          untracked = '',
          ignored = '',
          unstaged = '',
          staged = '',
          conflict = '',
        },
      },
    },
    commands = {
      system_open = function(state)
        vim.ui.open(state.tree:get_node():get_id())
      end,
      parent_or_close = function(state)
        local node = state.tree:get_node()
        if node:has_children() and node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
        end
      end,
      child_or_open = function(state)
        local node = state.tree:get_node()
        if node:has_children() then
          if not node:is_expanded() then
            state.commands.toggle_node(state)
          elseif node.type == 'file' then
            state.commands.open(state)
          else
            require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
          end
        else
          state.commands.open(state)
        end
      end,
      copy_selector = function(state)
        local node = state.tree:get_node()
        local filepath = node:get_id()
        local filename = node.name
        local modify = vim.fn.fnamemodify
        local vals = {
          ['BASENAME'] = modify(filename, ':r'),
          ['EXTENSION'] = modify(filename, ':e'),
          ['FILENAME'] = filename,
          ['PATH (CWD)'] = modify(filepath, ':.'),
          ['PATH (HOME)'] = modify(filepath, ':~'),
          ['PATH'] = filepath,
          ['URI'] = vim.uri_from_fname(filepath),
        }
        local options = vim.tbl_filter(function(val)
          return vals[val] ~= ''
        end, vim.tbl_keys(vals))
        if vim.tbl_isempty(options) then
          vim.notify('No values to copy', vim.log.levels.WARN)
          return
        end
        table.sort(options)
        vim.ui.select(options, {
          prompt = 'Choose to copy to clipboard:',
          format_item = function(item)
            return ('%s: %s'):format(item, vals[item])
          end,
        }, function(choice)
          local result = vals[choice]
          if result then
            vim.notify(('Copied: `%s`'):format(result))
            vim.fn.setreg('+', result)
          end
        end)
      end,
    },
    window = {
      width = 30,
      mappings = {
        ['<S-CR>'] = 'system_open',
        ['<Space>'] = false,
        ['[b'] = 'prev_source',
        [']b'] = 'next_source',
        O = 'system_open',
        Y = 'copy_selector',
        h = 'parent_or_close',
        l = 'child_or_open',
        P = {
          'toggle_preview',
          config = {
            use_float = false,
          },
        },
        ['T'] = 'none',
        ['t'] = function(state)
          local node = state.tree:get_node()
          local path = node.path
          if node.type ~= 'directory' then
            path = vim.fn.fnamemodify(path, ':h')
          end

          local Terminal = require('toggleterm.terminal').Terminal

          local dir_term = Terminal:new({
            dir = path,
            direction = 'float',
            close_on_exit = true,
          })

          dir_term:toggle()
        end,

        ['f'] = 'none',
        ['ff'] = function(state)
          local node = state.tree:get_node()
          local path = node.path

          if node.type ~= 'directory' then
            path = vim.fn.fnamemodify(path, ':h')
          end

          require('snacks.picker').files({
            cwd = path,
            title = 'Files: ' .. vim.fn.fnamemodify(path, ':t'),
            hidden = true,
            ignored = true,
          })
        end,
        ['fw'] = function(state)
          local node = state.tree:get_node()
          local path = node.path

          if node.type ~= 'directory' then
            path = vim.fn.fnamemodify(path, ':h')
          end

          require('snacks.picker').grep({
            cwd = path,
            title = 'Grep: ' .. vim.fn.fnamemodify(path, ':t'),
            hidden = true,
            ignored = true,
          })
        end,
      },
      fuzzy_finder_mappings = {
        ['<C-J>'] = 'move_cursor_down',
        ['<C-K>'] = 'move_cursor_up',
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      filtered_items = { hide_gitignored = git_available },
      hijack_netrw_behavior = 'open_current',
      use_libuv_file_watcher = vim.fn.has('win32') == 0,
    },
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.opt_local.signcolumn = 'auto'
          vim.opt_local.foldcolumn = '0'
        end,
      },
    },
  },
}
