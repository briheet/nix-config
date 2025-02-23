-- return {
--   { "ellisonleao/gruvbox.nvim" },
--
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "gruvbox",
--       transparent = true,
--     },
--   },
-- }

-- return {
--   {
--     "sainnhe/sonokai",
--     priority = 1000,
--     config = function()
--       vim.g.sonokai_transparent_background = "1"
--       vim.g.sonokai_enable_italic = "1"
--       vim.g.sonokai_style = "andromeda"
--       vim.cmd.colorscheme("sonokai")
--     end,
--   },
-- }

return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      vim.g.everforest_transparent_background = "1"
      vim.g.everforest_style = "andromeda"
      vim.g.everforest_enable_italic = true
      vim.cmd.colorscheme("everforest")
    end,
  },
}
--
-- return {
--   "AlexvZyl/nordic.nvim",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     require("nordic").load({
--       transparent = {
--         bg = true,
--       },
--     })
--   end,
-- }

-- return {
--   {
--     "craftzdog/solarized-osaka.nvim",
--     lazy = true,
--     priority = 1000,
--     opts = function()
--       return {
--         transparent = true,
--       }
--     end,
--   },
-- }
