-- Format on save; formatters missing from PATH are skipped, then LSP formatting is used.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      rust = { "rustfmt" },
      go = { "gofmt" },
      nix = { "nixfmt" },
      ocaml = { "ocamlformat" },
      python = { "ruff_format" },
      zig = { "zigfmt" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
  },
}
