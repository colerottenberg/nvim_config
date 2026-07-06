-- Avante (AI assistant). Native binary is built via the PackChanged hook in
-- bootstrap.lua (`make`); on a brand-new install a restart may be needed once
-- the build finishes. Disabled on Windows (matches the old config).

if vim.fn.has "win32" == 1 then return end

-- copilot.lua as a provider only -- suggestions/panel off so it doesn't fight
-- blink.cmp for inline completion.
pcall(
  function()
    require("copilot").setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
    }
  end
)

pcall(
  function()
    require("img-clip").setup {
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = { insert_mode = true },
        use_absolute_path = true,
      },
    }
  end
)

local ok, avante = pcall(require, "avante")
if not ok then
  vim.schedule(
    function()
      vim.notify("avante not available yet (native build may still be running; restart Neovim)", vim.log.levels.WARN)
    end
  )
  return
end

avante.setup {
  instructions_file = "avante.md",
  provider = "claude",
  mode = "agentic",
  providers = {
    claude = { model = "claude-opus-4-8" },
  },
}
