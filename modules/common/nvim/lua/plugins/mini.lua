-- mini.nvim modules: auto-close pairs, surround (sa/sd/sr), statusline.
return {
  "nvim-mini/mini.nvim",
  version = "*",
  lazy = false,
  config = function()
    require("mini.pairs").setup()
    require("mini.surround").setup()
    require("mini.statusline").setup()
  end,
}
