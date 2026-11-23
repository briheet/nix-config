-- Completion menu: LSP, paths, snippets, buffer words.
-- Keys (default preset): <C-space> open, <C-n>/<C-p> move, <C-y> accept, <C-e> close.
return {
  "saghen/blink.cmp",
  version = "1.*", -- v1 stable; uses a prebuilt fuzzy matcher for the release tag
  event = "InsertEnter",
  opts = {
    keymap = { preset = "default" },
    completion = { documentation = { auto_show = true } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
}
