{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # $EDITOR / $VISUAL = nvim

    # No remote-plugin providers; Lua plugins don't need them.
    withRuby = false;
    withPython3 = false;

    # git: lazy.nvim; tree-sitter: building parsers; ripgrep/fd: telescope;
    # nixfmt: conform
    extraPackages = with pkgs; [
      git
      tree-sitter
      ripgrep
      fd
      nixfmt
      # language servers only nvim uses (the rest are in helix.nix home.packages)
      lua-language-server
      bash-language-server
      vscode-langservers-extracted # jsonls
      yaml-language-server
    ];

    # Lua setup
    initLua = builtins.readFile ./nvim/init.lua;
  };

  # Plugin specs: modules/common/nvim/lua/plugins/*.lua
  xdg.configFile."nvim/lua".source = ./nvim/lua;
}
