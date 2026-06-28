-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
-- as this provides autocomplete and documentation while editing

local astro = require "astrocore"
local lazyjj = {
  callback = function()
    local worktree = astro.file_worktree()
    astro.toggle_term_cmd { cmd = "lazyjj ", direction = "float" }
  end,
  desc = "ToggleTerm lazyjj",
}

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
      update_in_insert = true,
    },
    -- passed to `vim.filetype.add`
    -- filetypes = {
    --   -- see `:h vim.filetype.add` for usage
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     [".foorc"] = "fooscript",
    --   },
    --   pattern = {
    --     [".*/etc/foo/.*"] = "fooscript",
    --   },
    -- },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
        exrc = true, -- enabling excr to read .nvim.lua
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map
        -- navigate buffer tabs
        -- ["L"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        -- ["H"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
        -- Adding New Navigation Due to Change from AstroCore Bufferline to Bufferline
        ["L"] = {
          function() require("bufferline.commands").cycle(vim.v.count1) end,
          desc = "Next buffer",
        },
        ["H"] = {
          function() require("bufferline.commands").cycle(-vim.v.count1) end,
          desc = "Previous buffer",
        },

        -- ── DAP function keys (VS Code-style) ────────────────────────────
        -- These must live here (astrocore mappings), not in the nvim-dap
        -- `keys` field: AstroNvim core (astronvim.plugins.dap) already binds
        -- these via astrocore, so a lazy `keys` mapping gets shadowed.
        -- Terminal keycode note: most terminals send Shift+F5 as <F17> and
        -- Shift+F11 as <F23> (legacy xterm F13–F24 encoding); newer terminals
        -- with the kitty/CSI-u protocol send <S-F5>/<S-F11>. Bind both so it
        -- works either way. (`:h terminal-info`, or `nvim -V3log +q` to inspect.)
        ["<F5>"] = { function() require("dap").continue() end, desc = "Debugger: continue / start" },
        ["<F6>"] = { function() require("dap").pause() end, desc = "Debugger: pause" },
        ["<F9>"] = { function() require("dap").toggle_breakpoint() end, desc = "Debugger: toggle breakpoint" },
        ["<F10>"] = { function() require("dap").step_over() end, desc = "Debugger: step over" },
        ["<F11>"] = { function() require("dap").step_into() end, desc = "Debugger: step into" },
        ["<F17>"] = { function() require("dap").terminate() end, desc = "Debugger: terminate (Shift+F5)" },
        ["<S-F5>"] = { function() require("dap").terminate() end, desc = "Debugger: terminate" },
        ["<F23>"] = { function() require("dap").step_out() end, desc = "Debugger: step out (Shift+F11)" },
        ["<S-F11>"] = { function() require("dap").step_out() end, desc = "Debugger: step out" },

        -- K shows the value under the cursor while debugging, else normal LSP
        -- hover. Mapping K ourselves stops Neovim's default LSP `K` from taking
        -- over (it only auto-binds K when it isn't already mapped). Guarding on
        -- `package.loaded.dap` avoids loading nvim-dap just by pressing K.
        ["K"] = {
          function()
            local dap = package.loaded.dap
            if dap and dap.session() then
              require("dapui").eval(nil, { enter = false })
            else
              vim.lsp.buf.hover()
            end
          end,
          desc = "Hover symbol (value while debugging)",
        },

        ["<Leader>ly"] = {
          desc = "View Type Heirarchy",
        },

        ["<Leader>lyi"] = {
          function()
            local config = {}
            vim.lsp.buf.typehierarchy "subtypes"
          end,
          desc = "View subtypes",
        },

        ["<Leader>lyo"] = {
          function()
            local config = {}
            vim.lsp.buf.typehierarchy "supertypes"
          end,
          desc = "View supertypes",
        },

        ["ga"] = {
          desc = "View Calls",
        },
        ["gai"] = {
          function()
            ---@type snacks.picker.lsp.Config
            local lsp_config = { focus = "list" }
            require("snacks.picker").lsp_incoming_calls(lsp_config)
          end,
          desc = "Incoming Calls",
        },
        ["gao"] = {
          function()
            ---@type snacks.picker.lsp.Config
            local lsp_config = { focus = "list" }
            require("snacks.picker").lsp_outgoing_calls(lsp_config)
          end,
          desc = "Outgoing Calls",
        },
        ["gw"] = {
          function()
            require("snacks.picker").projects {
              confirm = function(picker, item)
                picker:close()
                if item and item.path then
                  vim.lsp.buf.add_workspace_folder(item.path)
                  require("snacks.notify").info("Added workspace folder: " .. item.path, { title = "LSP Workspace" })
                end
              end,
            }
          end,
          desc = "Add Workspace Folder",
        },
        ["gR"] = {
          function()
            ---@type snacks.picker.lsp.references.Config
            local ref_config = { focus = "list" }
            require("snacks.picker").lsp_references(ref_config)
          end,
          desc = "Lsp References",
        },
        -- Change LSP Symbols view to enter normal mode to aid navigation speed
        ["<Leader>ls"] = {
          function()
            ---@type snacks.picker.lsp.symbols.Config
            local ws_config = { focus = "list" }
            require("snacks.picker").lsp_symbols(ws_config)
          end,
          desc = "Search Symbols",
        },
        ["<Leader>lR"] = {
          function()
            ---@type snacks.picker.lsp.references.Config
            local ref_config = { focus = "list" }
            require("snacks.picker").lsp_references(ref_config)
          end,
          desc = "Lsp References",
        },
        ["<Leader>lW"] = {
          function()
            require("snacks.picker").projects {
              confirm = function(picker, item)
                picker:close()
                if item and item.path then
                  vim.lsp.buf.add_workspace_folder(item.path)
                  require("snacks.notify").info("Added workspace folder: " .. item.path, { title = "LSP Workspace" })
                end
              end,
            }
          end,
          desc = "Add Workspace Folder",
        },
        ["<Leader>lc"] = {
          function() require("snacks.picker").lsp_config() end,
          desc = "LSP Config",
        },
        ["<Leader>lg"] = {
          function() require("snacks.picker").lsp_workspace_symbols() end,
          desc = "Search workspace symbols",
        },

        -- remapping ld to search project diagnostics
        ["<Leader>lD"] = false,
        ["<Leader>ld"] = {
          function()
            ---@type snacks.picker.Config
            local config = { focus = "list" }
            require("snacks.picker").diagnostics(config)
          end,
          desc = "Search Diagnostics",
        },
        ["<Leader>lG"] = false,
        ["<Leader>ft"] = {
          function()
            ---@type snacks.picker.Config
            local cs_config = { focus = "list", layout = "ivy" }
            require("snacks.picker").colorschemes(cs_config)
          end,
          desc = "Find themese",
        },

        ["<Leader>fb"] = {
          function()
            ---@type snacks.picker.buffers.Config
            local config = {
              focus = "list",
            }
            require("snacks").picker.buffers(config)
          end,
        },
        -- Changin Zen Mode to just center
        ["<Leader>uZ"] = {
          function()
            -- Calculate dynamic width based on terminal size
            -- Use 70% of available columns, but cap at 150 and minimum of 80
            local columns = vim.o.columns
            local dynamic_width = math.floor(columns * 0.70)
            dynamic_width = math.min(dynamic_width, 150) -- cap at 150
            dynamic_width = math.max(dynamic_width, 80) -- minimum of 80

            ---@type snacks.zen.Config
            local zen_config = {
              toggles = {},
              show = {
                tabline = true,
                statusline = true,
              },
              ---@type snacks.win.Config
              win = {
                -- backdrop = false,
                width = dynamic_width,
              },
              center = true,
            }
            require("snacks.zen").zen(zen_config)
          end,
        },
        ["<Leader>gc"] = {
          function()
            ---@type snacks.picker.git.log.Config
            local git_log_config = { focus = "list" }
            require("snacks.picker").git_log(git_log_config)
          end,
          desc = "Git commits (repository)",
        },
        ["<Leader>gC"] = {
          function()
            ---@type snacks.picker.git.log.Config
            local git_log_config = { focus = "list", current_file = true, follow = true }
            require("snacks.picker").git_log(git_log_config)
          end,
          desc = "Git commits (file)",
        },
        ["<Leader>gb"] = {
          function()
            ---@type snacks.picker.git.branches.Config
            local config = { focus = "list" }
            require("snacks.picker").git_branches(config)
          end,
          desc = "Git log",
        },
        ["<Leader>gM"] = {
          function()
            ---@type snacks.picker.git.log.Config
            local config = { focus = "list" }
            require("snacks.picker").git_log_line(config)
          end,
          desc = "Git Log Line",
        },
        ["<Leader>gP"] = {
          function() require("gitsigns").preview_hunk() end,
          desc = "Git Preview Hunks",
        },
        -- plugin manager
        ["<Leader>pr"] = {
          function() require("astrocore").reload() end,
          desc = "Reload neovim",
        },

        -- Adding LazyJJ Tui for Jujustu
        ["<Leader>jj"] = lazyjj,
        ["<Leader>tj"] = lazyjj,
        -- mappings seen under group name "Buffer"
        -- ["<Leader>bd"] = {
        --   function()
        --     require("astroui.status.heirline").buffer_picker(
        --       function(bufnr) require("astrocore.buffer").close(bufnr) end
        --     )
        --   end,
        --   desc = "Close buffer from tabline",
        -- },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },
        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
