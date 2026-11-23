{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # $EDITOR / $VISUAL = nvim

    # No remote-plugin providers; Lua plugins don't need them.
    withRuby = false;
    withPython3 = false;

    # git: lazy.nvim; tree-sitter: building parsers; ripgrep/fd: telescope;
    # nixfmt: conform (other servers/formatters are in helix.nix home.packages)
    extraPackages = with pkgs; [
      git
      tree-sitter
      ripgrep
      fd
      nixfmt
    ];

    # Lua setup
    initLua = builtins.readFile ./nvim/init.lua;
  };

  # Plugin specs: modules/common/nvim/lua/plugins/*.lua
  xdg.configFile."nvim/lua".source = ./nvim/lua;
}
