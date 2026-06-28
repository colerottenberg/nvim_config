-- Rust-only keymaps (buffer-local). Lives in after/ftplugin so it loads for
-- filetype=rust ONLY -- nothing here affects other filetypes.
--
-- rustaceanvim does not support rust-analyzer's Run/Debug CodeLens, so the
-- built-in `grx` (vim.lsp.codelens.run) crashes for Rust. We shadow it here to
-- call the working `:RustLsp` commands instead. `:RustLsp` is buffer-local and
-- only exists after rust-analyzer attaches; these bodies run lazily on keypress.

local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc }) end

-- Prompt for extra executable args, then run the given :RustLsp subcommand.
-- Args must be passed as a list so each token becomes a separate argument;
-- a single "subcmd args" string is read by :RustLsp as one (unknown) subcommand.
local function with_args(subcmd)
  return function()
    vim.ui.input({ prompt = subcmd .. " args: " }, function(input)
      if input == nil then return end -- cancelled
      local cmd = vim.split(input, "%s+", { trimempty = true })
      table.insert(cmd, 1, subcmd)
      vim.cmd.RustLsp(cmd)
    end)
  end
end

-- LocalLeader (`,`) menu for everything else.
map("<LocalLeader>R", function() vim.cmd.RustLsp "runnables" end, "Rust: pick a runnable")
map("<LocalLeader>D", function() vim.cmd.RustLsp "debuggables" end, "Rust: pick a debuggable")
map("<LocalLeader>t", function() vim.cmd.RustLsp "testables" end, "Rust: pick a testable")
map("<LocalLeader>l", function() vim.cmd.RustLsp { "run", bang = true } end, "Rust: re-run last target")
map("<LocalLeader>j", function() vim.cmd.RustLsp { "debug", bang = true } end, "Rust: re-debug last target")
map("<LocalLeader>a", with_args "run", "Rust: run with args")
map("<LocalLeader>A", with_args "debug", "Rust: debug with args")
map("<LocalLeader>k", function() vim.cmd.RustLsp { "hover", "actions" } end, "Rust: hover actions")
map("<LocalLeader>e", function() vim.cmd.RustLsp "explainError" end, "Rust: explain error")
