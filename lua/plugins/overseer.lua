-- Task runner.

return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerOpen', 'OverseerClose', 'OverseerToggle', 'OverseerShell', 'OverseerRun', 'OverseerTaskAction' },
  keys = {
    { '<Leader>mt', '<Cmd>OverseerToggle<CR>', desc = 'Toggle Overseer' },
    { '<Leader>mc', '<Cmd>OverseerShell<CR>', desc = 'Run command' },
    { '<Leader>mr', '<Cmd>OverseerRun<CR>', desc = 'Run task' },
    { '<Leader>M', '<Cmd>OverseerRun<CR>', desc = 'Run task' },
    { '<Leader>ma', '<Cmd>OverseerTaskAction<CR>', desc = 'Task action' },
    {
      '<Leader>mi',
      function()
        vim.cmd.checkhealth('overseer')
      end,
      desc = 'Overseer info',
    },
  },
  config = function()
    local opts = {
      strategy = pcall(require, 'toggleterm') and 'toggleterm' or 'terminal',
      task_list = {
        bindings = {
          ['<C-l>'] = false,
          ['<C-h>'] = false,
          ['<C-k>'] = false,
          ['<C-j>'] = false,
          ['q'] = '<Cmd>close<CR>',
          ['K'] = 'IncreaseDetail',
          ['J'] = 'DecreaseDetail',
          ['<C-p>'] = 'ScrollOutputUp',
          ['<C-n>'] = 'ScrollOutputDown',
        },
      },
    }
    local overseer = require('overseer')
    overseer.setup(opts)
    overseer.register_template({
      name = 'Invoke Tasks',
      generator = function(opts, cb)
        -- Run 'inv --list' to parse available Python tasks
        vim.fn.jobstart({ 'inv', '--list' }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if not data then
              return
            end

            local tasks = {}
            local parsing_tasks = false

            for _, line in ipairs(data) do
              -- Detect the start of the task listings
              if line:match('^Available tasks:') then
                parsing_tasks = true
              elseif parsing_tasks and line:match('^%s+(%S+)') then
                -- Extract the task name and description
                local task_name, desc = line:match('^%s+(%S+)%s*(.*)')
                if task_name then
                  table.insert(tasks, {
                    name = 'inv ' .. task_name,
                    desc = desc ~= '' and desc or 'Run python invoke task: ' .. task_name,
                    params = {
                      args = { type = 'string', optional = true, desc = 'Additional arguments' },
                    },
                    builder = function(params)
                      local cmd_args = { task_name }
                      if params.args and params.args ~= '' then
                        -- Append user-defined CLI arguments safely
                        for arg in string.gmatch(params.args, '%S+') do
                          table.insert(cmd_args, arg)
                        end
                      end
                      return {
                        cmd = { 'inv' },
                        args = cmd_args,
                        components = { 'default' }, -- Leverages quickfix, diagnostics, etc.
                      }
                    end,
                  })
                end
              end
            end

            cb(tasks)
          end,
          on_stderr = function()
            cb({}) -- Gracefully fail if 'inv' is not found or fails
          end,
        })
      end,
      -- Only activate this provider if a tasks.py file exists in the directory
      condition = {
        callback = function(search)
          return vim.fn.filereadable(search.dir .. '/tasks.py') == 1
        end,
      },
    })
  end,
}
