-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

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
        ["L"] = { function() require("bufferline.commands").cycle(vim.v.count1) end, desc = "Next buffer" },
        ["H"] = { function() require("bufferline.commands").cycle(-vim.v.count1) end, desc = "Previous buffer" },

        ["<Leader>gmf"] = {
          function() require("snacks.lazygit").log_file() end,
          desc = "Git log file",
        },

        ["ga"] = {
          desc = "View Calls",
        },

        ["gai"] = {
          function()
            ---@type snacks.picker.lsp.Config
            local lsp_config = {
              focus = "list",
            }
            require("snacks.picker").lsp_incoming_calls(lsp_config)
          end,
          desc = "Incoming Calls",
        },
        ["gao"] = {
          function()
            ---@type snacks.picker.lsp.Config
            local lsp_config = {
              focus = "list",
            }
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
            local ref_config = {
              focus = "list",
            }
            require("snacks.picker").lsp_references(ref_config)
          end,
          desc = "Lsp References",
        },

        -- Change LSP Symbols view to enter normal mode to aid navigation speed
        ["<Leader>ls"] = {
          function()
            ---@type snacks.picker.lsp.symbols.Config
            local ws_config = {
              focus = "list",
            }
            require("snacks.picker").lsp_symbols(ws_config)
          end,
          desc = "Search Workspace Symbols",
        },

        ["<Leader>lR"] = {
          function()
            ---@type snacks.picker.lsp.references.Config
            local ref_config = {
              focus = "list",
            }
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

        ["<Leader>lG"] = false,

        ["<Leader>ft"] = {
          function()
            ---@type snacks.picker.Config
            local cs_config = {
              focus = "list",
              layout = "ivy",
            }
            require("snacks.picker").colorschemes(cs_config)
          end,
          desc = "Find themese",
        },

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
