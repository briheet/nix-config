-- Language servers. Binaries come from home.packages (modules/common/helix.nix) and,
-- for lua_ls/bashls/jsonls/yamlls, programs.neovim.extraPackages (modules/common/nvim.nix);
-- nvim-lspconfig only supplies each server's settings for vim.lsp.enable.
-- Built-in keys: K hover, grn rename, gra code action, grr references,
-- gri implementation, gO symbols, [d ]d diagnostics, <C-s> signature help.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "saghen/blink.cmp" },
  config = function()
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

    -- lua_ls: treat files as Neovim Lua (LuaJIT, the `vim` global, Neovim's runtime API)
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    vim.lsp.enable({
      "rust_analyzer",
      "gopls",
      "golangci_lint_ls",
      "nixd",
      "ocamllsp",
      "expert", -- Elixir
      "ty",
      "ruff",
      "ts_ls",
      "zls",
      "lua_ls", -- Neovim's own Lua config (settings below)
      "bashls",
      "jsonls",
      "yamlls",
    })

    vim.diagnostic.config({ virtual_text = true, severity_sort = true })

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  end,
}
