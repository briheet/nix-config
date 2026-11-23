vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.mouse = "a"
vim.opt.number = true         -- current line shows its absolute number
vim.opt.relativenumber = true -- other lines show their distance from it
vim.opt.signcolumn = "yes"    -- always reserve the git/diagnostic column so text never shifts
vim.opt.cursorline = true     -- highlight the current line
vim.opt.ignorecase = true     -- /foo matches Foo and FOO ...
vim.opt.smartcase = true      -- ... unless the search has a capital: /Foo matches only Foo
vim.opt.scrolloff = 999 -- keep the cursor centred; j/k scroll the text behind it
vim.opt.splitright = true -- :vsplit opens the new window on the right (and moves there)
vim.opt.splitbelow = true -- :split opens it below
vim.keymap.set("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Split side by side" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })

-- lazy.nvim: installs itself on first start, then plugins from lua/plugins/*.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  -- Pinned versions live in the repo; commit this file after :Lazy update.
  lockfile = vim.fn.expand("~/nix-config/modules/common/nvim/lazy-lock.json"),
  rocks = { enabled = false }, -- no plugin needs luarocks
  checker = { enabled = false },
  change_detection = { enabled = false }, -- config is a read-only nix symlink
})
