return {
  "nvim-telescope/telescope.nvim",
  version = "*", -- latest release tag
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    -- Like Helix space F: only files under the current file's directory
    { "<leader>fd", function() require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") }) end,
      desc = "Find files in current file's directory" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
  },
  config = function()
    -- Scroll the preview a few lines per press; hold J/K for smooth scrolling.
    local function scroll_preview(lines)
      return function(prompt_bufnr)
        local previewer = require("telescope.actions.state").get_current_picker(prompt_bufnr).previewer
        if type(previewer) == "table" and previewer.scroll_fn then previewer:scroll_fn(lines) end
      end
    end

    require("telescope").setup({
      defaults = {
        mappings = {
          n = { ["J"] = scroll_preview(3), ["K"] = scroll_preview(-3) }, -- picker normal mode (Esc once)
        },
      },
    })
    require("telescope").load_extension("fzf")
  end,
}
