-- Shows available keys after a prefix such as <leader>.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>h", group = "git hunk" },
    },
  },
}
