return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Author, age and summary of the commit that last changed the cursor line, at its end
    current_line_blame = true,
    current_line_blame_opts = { delay = 300 },
    current_line_blame_formatter = "<author>, <author_time:%R> · <summary>",
    on_attach = function(buf)
      local gs = require("gitsigns")
      local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
      map("]h", function() gs.nav_hunk("next") end, "Next hunk")
      map("[h", function() gs.nav_hunk("prev") end, "Previous hunk")
      map("<leader>hp", gs.preview_hunk, "Preview hunk")
      map("<leader>hs", gs.stage_hunk, "Stage hunk")
      map("<leader>hr", gs.reset_hunk, "Reset hunk")
      map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line (full commit)")
      map("<leader>hB", gs.toggle_current_line_blame, "Toggle inline blame")
    end,
  },
}
