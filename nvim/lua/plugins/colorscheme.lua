return {
	"craftzdog/solarized-osaka.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("solarized-osaka").setup({})
		vim.cmd.colorscheme("solarized-osaka")
	end,
	opts = {},
}

-- return {
-- 	"AlexvZyl/nordic.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("nordic").load({
-- 			transparent = {
-- 				bg = true,
-- 			},
-- 		})
-- 	end,
-- }

-- return {
-- 	"ellisonleao/gruvbox.nvim",
-- 	priority = 1000,
-- 	opts = {
-- 		transparent_mode = true,
-- 		contrast = "soft",
-- 	},
-- 	config = function(_, opts)
-- 		require("gruvbox").setup(opts)
-- 		vim.cmd.colorscheme("gruvbox")
-- 	end,
-- }
