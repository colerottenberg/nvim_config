-- Agent backend selection: NVIM_AI=claude|opencode, else opencode, else claude.

local M = {}

local function resolve()
  local want = vim.env.NVIM_AI
  if want == 'claude' or want == 'opencode' then
    return want
  end
  if vim.fn.executable('opencode') == 1 then
    return 'opencode'
  end
  if vim.fn.executable('claude') == 1 then
    return 'claude'
  end
  return 'none'
end

M.backend = resolve()

---@param name 'claude'|'opencode'
function M.is(name)
  return M.backend == name
end

return M
