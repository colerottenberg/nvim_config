require("csvview").setup {
  view = {
    display_mode = "border",
    sticky_header = {
      enabled = true,
      separator = "-",
    },
  },
  parser = {
    delimiter = {
      ft = {
        csv = ",",
        tsv = "\t",
      },
      fallbacks = {
        ",",
        "\t",
        ";",
      },
    },
    comments = {
      "#",
      "--",
      "//",
    },
  },
  keymaps = {
    jump_next_field_start = {
      "w",
      mode = { "n", "v" },
    },
    jump_prev_field_start = {
      "b",
      mode = { "n", "v" },
    },
    jump_next_row = {
      "j",
      mode = { "n", "v" },
    },
    jump_prev_row = {
      "k",
      mode = { "n", "v" },
    },

    textobject_field_inner = {
      "ic",
      mode = { "o", "x" },
      desc = "cell",
    },
    textobject_field_outer = {
      "ac",
      mode = { "o", "x" },
      desc = "cell",
    },
  },
}
