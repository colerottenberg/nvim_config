-- Git signs + per-buffer git hunk mappings. Ported from AstroNvim's gitsigns.

if vim.fn.executable "git" ~= 1 then return end

local sign = { text = "▍" }
require("gitsigns").setup {
  signs = { add = sign, change = sign, delete = sign, topdelete = sign, changedelete = sign, untracked = sign },
  signs_staged = { add = sign, change = sign, delete = sign, topdelete = sign, changedelete = sign, untracked = sign },
  on_attach = function(bufnr)
    local gs = require "gitsigns"
    local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end

    map("n", "]g", function() gs.nav_hunk "next" end, "Next hunk")
    map("n", "[g", function() gs.nav_hunk "prev" end, "Previous hunk")
    map("n", "]G", function() gs.nav_hunk "last" end, "Last hunk")
    map("n", "[G", function() gs.nav_hunk "first" end, "First hunk")
    map("n", "<Leader>gl", function() gs.blame_line() end, "View git blame")
    map("n", "<Leader>gL", function() gs.blame_line { full = true } end, "View full git blame")
    map("n", "<Leader>gp", function() gs.preview_hunk() end, "Preview git hunk")
    map("n", "<Leader>gr", function() gs.reset_hunk() end, "Reset git hunk")
    map("v", "<Leader>gr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end, "Reset git hunk")
    map("n", "<Leader>gR", function() gs.reset_buffer() end, "Reset git buffer")
    map("n", "<Leader>gs", function() gs.stage_hunk() end, "Stage git hunk")
    map("v", "<Leader>gs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end, "Stage git hunk")
    map("n", "<Leader>gS", function() gs.stage_buffer() end, "Stage git buffer")
    map("n", "<Leader>gd", function() gs.diffthis() end, "View git diff")
    map({ "o", "x" }, "ig", gs.select_hunk, "Select git hunk")
  end,
}
