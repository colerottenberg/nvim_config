-- Python-only: registers the uv-based debugpy adapter and configs
-- (lua/dap_py.lua) so `<Leader>dc` etc. show Python configs. Loads for
-- filetype=python ONLY -- nothing here affects other filetypes.
local dap_py = require "dap_py"
dap_py.setup()

local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc }) end

map("<LocalLeader>f", function() dap_py.run "file: current" end, "Run current file")
map("<LocalLeader>t", function() dap_py.run "pytest: current file" end, "DAP: pytest current file")
map("<LocalLeader>T", function() dap_py.run "pytest: whole suite" end, "DAP: pytest suite")
map("<LocalLeader>c", function() dap_py.run "cli: entry point" end, "DAP: CLI entry point")
map("<LocalLeader>C", function() dap_py.run "cli: list entry points" end, "DAP: list CLI entry points")
