-- File explorer: your yazi (modules/common/yazi.nix) in a floating window.
-- Space e: at the current file   Space E: at nvim's working directory
-- Opening a directory (nvim ., :e dir/) also opens yazi instead of netrw.
return {
  "mikavilpas/yazi.nvim",
  version = "*", -- latest stable release
  event = "VeryLazy",
  dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
  keys = {
    { "<leader>e", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "File explorer (current file)" },
    { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "File explorer (working directory)" },
  },
  opts = {
    open_for_directories = true,
    keymaps = { show_help = "<f1>" },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1 -- yazi replaces netrw for directories
  end,
}
