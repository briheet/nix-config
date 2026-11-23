-- Statusline: one bar for all splits, catppuccin colours.
-- mode | branch, diff (+~-), diagnostics | relative path [+] ... LSP | filetype | % | line:col
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      theme = "catppuccin",
      globalstatus = true,
      component_separators = "",
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        "branch",
        {
          "diff",
          source = function() -- reuse gitsigns' counts instead of running git again
            local g = vim.b.gitsigns_status_dict
            if g then return { added = g.added, modified = g.changed, removed = g.removed } end
          end,
        },
        "diagnostics",
      },
      lualine_c = { { "filename", path = 1, symbols = { modified = " [+]", readonly = " [ro]" } } },
      lualine_x = {
        { -- names of the language servers attached to this buffer
          function()
            local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
            return #names > 0 and (" " .. table.concat(names, ", ")) or ""
          end,
        },
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
