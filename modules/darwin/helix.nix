{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    rustc
    rust-analyzer
    rustfmt
    cargo

    gopls
    go_1_25
    goperf
    golangci-lint
    golangci-lint-langserver
    delve

    zig_0_15
    zls

    nil
    nixd
    alejandra

    ocaml
    opam
    ocamlPackages.ocaml-lsp
    ocamlformat
    ocamlPackages.earlybird
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "everforest_dark_transparent";
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

    themes = {
      everforest_dark_transparent = {
        inherits = "everforest_dark";

        "ui.background" = "none";
      };
    };

    # themes.everforest_dark = {
    #   inherits = "solarized_dark";
    #   "ui.background" = { };
    #   "ui.statusline" = { };
    #   "ui.gutter" = { };
    # };

    languages.language = [
      {
        name = "go";
        roots = [
          "go.work"
          "go.mod"
        ];
        auto-format = true;
        formatter.command = "gofmt";
        language-servers = [
          "gopls"
          "golangci-lint-lsp"
        ];
      }
      {
        name = "rust";
        auto-format = true;
        formatter = {
          command = "rustfmt";
          args = [
            "--edition"
            "2024"
          ];
        };
        language-servers = [ "rust-analyzer" ];
      }
      {
        name = "nix";
        formatter = {
          command = lib.getExe pkgs.nixfmt;
        };
        auto-format = true;
      }
      {
        name = "ocaml";
        auto-format = true;
        formatter.command = "ocamlformat";
        formatter.args = [
          "--enable-outside-detected-project"
          "-"
        ];
        debugger = {
          name = "ocamlearlybird";
          transport = "tcp";
          command = "ocamlearlybird";
          args = [ "debug" ];
          port-arg = "--port={}";
          templates = [
            {
              name = "launch";
              request = "launch";
              completion = [
                {
                  name = "program";
                  completion = "filename";
                }
              ];
              args.program = "{0}";
            }
          ];
        };
      }
      {
        name = "cpp";
        auto-format = true;
      }
    ];

    languages.language-server.golangci-lint-lsp = {
      command = "golangci-lint-langserver";
      config.command = [
        "golangci-lint"
        "run"
        "--path-mode=abs"
        "--output.json.path=stdout"
        "--output.text.path=/dev/null"
        "--show-stats=false"
        "--issues-exit-code=1"
      ];
    };

    # Surface Go escape analysis / GC hints inline via gopls.
    languages.language-server.gopls.config = {
      "ui.codelenses" = {
        gc_details = true;
      };
      "ui.diagnostic.annotations" = {
        escape = true;
        inline = true;
      };
    };

    languages.language-server.rust-analyzer.config = {
      check.command = "clippy";
      # cargo.allFeatures = true;
    };

  };
}
