-- nvim-treesitter (main branch): installs parsers; Neovim does the highlighting.
-- Needs tree-sitter CLI (nvim.nix extraPackages) and a C compiler.
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false, -- does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "bash", "elixir", "go", "javascript", "json", "nix", "python",
      "rust", "toml", "typescript", "yaml",
    })

    -- Highlight every buffer whose filetype has a parser installed.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
    })
  end,
}
