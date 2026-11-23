-- Catppuccin Mocha, transparent like the Helix theme.
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000, -- load before other plugins
  opts = { flavour = "mocha", transparent_background = true },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
