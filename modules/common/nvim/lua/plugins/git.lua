return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(buf)
      local gs = require("gitsigns")
      local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
      map("]h", function() gs.nav_hunk("next") end, "Next hunk")
      map("[h", function() gs.nav_hunk("prev") end, "Previous hunk")
      map("<leader>hp", gs.preview_hunk, "Preview hunk")
      map("<leader>hs", gs.stage_hunk, "Stage hunk")
      map("<leader>hr", gs.reset_hunk, "Reset hunk")
      map("<leader>hb", gs.blame_line, "Blame line")
    end,
  },
}
