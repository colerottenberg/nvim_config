-- Avante (AI assistant). The native binary is built by lazy's `build = "make"`
-- on install/update. Disabled on Windows (matches the old config).

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  build = "make",
  cond = vim.fn.has "win32" == 0,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-mini/mini.pick",
    "nvim-telescope/telescope.nvim",
    "ibhagwan/fzf-lua",
    "stevearc/dressing.nvim",
    "folke/snacks.nvim",
    "MeanderingProgrammer/render-markdown.nvim",
    {
      -- copilot.lua as a provider only -- suggestions/panel off so it doesn't
      -- fight blink.cmp for inline completion.
      "zbirenbaum/copilot.lua",
      opts = {
        suggestion = { enabled = false },
        panel = { enabled = false },
      },
    },
    {
      -- image pasting
      "HakonHarnes/img-clip.nvim",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = { insert_mode = true },
          use_absolute_path = true,
        },
      },
    },
  },
  opts = {
    instructions_file = "avante.md",
    provider = "claude",
    mode = "agentic",
    providers = {
      claude = { model = "claude-opus-4-8" },
    },
  },
}
