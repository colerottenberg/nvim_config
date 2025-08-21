-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
local o = vim.o
if jit.os == "Windows" then
  o.shell = vim.fn.executable "pwsh" and "pwsh" or "powershell"
  o.shellcmdflag =
    "-NoLogo -NoProfile -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  o.shellquote = ""
  o.shellxquote = ""
end
