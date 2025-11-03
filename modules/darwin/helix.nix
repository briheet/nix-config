{ pkgs, ... }:

{
  home.packages = with pkgs; [
    rust-analyzer
    rustfmt

    gopls
    go_1_25
    goperf
    golangci-lint-langserver
    delve
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "everforest_dark";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };

    themes.everforest_dark = {
      inherits = "everforest_dark";
      "ui.background" = {};
      "ui.statusline" = {};
      "ui.gutter" = {};
    };

    languages.language-server.golangci-lint-lsp = {
      command = "golangci-lint-langserver";
      config.command = [
        "golangci-lint"
        "run"
        # "--path-mode=abs"
        # "--output-format=json:stdout"
        # "--out-format=line-number"
      ];
    };

    languages.language-server.rust-analyzer.config = {
      checkOnSave.command = "clippy";
      cargo.allFeatures = true;
    };

    languages.language-server.discord-rpc = {
      command = "/Users/briheet/go/bin/discord-rpc-lsp";
    };

    languages.language = [
      {
        name = "go";
        roots = [ "go.work" "go.mod" ];
        auto-format = true;
        formatter.command = "gofmt";
        language-servers = [ "gopls" "golangci-lint-lsp" "discord-rpc" ];
      }
      {
        name = "rust";
        auto-format = true;
        formatter = {
          command = "rustfmt";
          args = [ "--edition" "2021" ];
        };
        language-servers = [ "rust-analyzer" "discord-rpc" ];
      }
    ];
  };
}
