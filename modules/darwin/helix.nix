{ pkgs, ... }:

{
  home.packages = with pkgs; [
    helix

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
      };
    };

    languages = {
      language-server = {

        "golangci-lint-lsp" = {
          command = "golangci-lint-langserver";
          config = {
            command = [
              "golangci-lint"
              "run"
              "--path-mode=abs"
              "--output.json.path=stdout"
              "--output.text.path=/dev/null"
              "--show-stats=false"
              "--issues-exit-code=1"
            ];
          };
        };

        "rust-analyzer" = {
          config = {
            checkOnSave = { command = "clippy"; };
            cargo = { allFeatures = true; };
          };
        };
      };

      language = [
        {
          name = "go";
          roots = [ "go.work" "go.mod" ];
          auto-format = true;
          formatter = {
            command = "gofmt";
          };
          comment-token = "//";
          language-servers = [ "gopls" "golangci-lint-lsp" ];
        }

        {
          name = "rust";
          auto-format = true;
          formatter = {
            command = "rustfmt";
            args = [ "--edition" "2021" ];
          };
        }
      ];
    };
  };
}
