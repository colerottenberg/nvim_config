return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      n = {
        L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
      },
    },
  },
}
