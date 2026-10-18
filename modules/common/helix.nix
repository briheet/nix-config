{ pkgs, lib, ... }:

let
  # Our work projects use Elixir 1.20 on OTP 28.
  # elixir = pkgs.beam.packages.erlang_28.elixir_1_20;

  # nixpkgs patches ElixirLS's launcher to pin the Elixir it was built with.
  # Drop that patch so the upstream launcher picks up whichever Elixir the
  # project resolves to (asdf, mise or PATH) and compiles ElixirLS for it.
  elixirLs = pkgs.elixir-ls.overrideAttrs { patches = [ ]; };

  prettierFormatter = parser: {
    command = "prettier";
    args = [
      "--parser"
      parser
    ];
  };

  jsDebugger = {
    name = "js-debug";
    transport = "tcp";
    command = "js-debug";
    port-arg = "{}";
    templates = [
      {
        name = "source";
        request = "launch";
        completion = [
          {
            name = "entrypoint";
            completion = "filename";
            default = ".";
          }
        ];
        args = {
          type = "node";
          program = "{0}";
          sourceMaps = true;
          skipFiles = [ "<node_internals>/**" ];
        };
      }
    ];
  };
in

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

    zig_0_16
    zls
    bazelisk

    nil
    nixd
    alejandra

    ocaml
    opam
    ocamlPackages.ocaml-lsp
    ocamlformat
    ocamlPackages.earlybird

    # Elixir
    beamPackages.elixir
    elixirLs

    # Python
    python313
    ty
    ruff
    python313Packages.debugpy
    # python313Packages.jedi-language-server
    python313Packages.python-lsp-server

    typescript-language-server
    typescript
    vscode-js-debug
    prettier
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    # Keep the theme's palette; let Ghostty's existing transparency show through.
    # Nord (previous theme):
    # themes.nord-transparent = {
    #   inherits = "nord";
    #   "ui.background" = { };
    # };
    themes.catppuccin_mocha-transparent = {
      inherits = "catppuccin_mocha";
      "ui.background" = { };
    };

    settings = {
      # theme = "nord-transparent";
      theme = "catppuccin_mocha-transparent";
      keys.normal.space.F = "file_picker_in_current_buffer_directory";
      editor = {
        # rulers = [ 80 ];
        line-number = "relative";
        lsp.display-messages = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };

    languages.language = [
      {
        name = "elixir";
        roots = [
          "mix.exs"
          ".git"
        ];
        # elixir-ls formats via `mix format`, honouring the project's .formatter.exs.
        auto-format = true;
        language-servers = [ "elixir-ls" ];
      }
      {
        name = "heex";
        roots = [
          "mix.exs"
          ".git"
        ];
        # No auto-format on HEEx templates.
        language-servers = [ "elixir-ls" ];
      }
      {
        name = "eex";
        roots = [
          "mix.exs"
          ".git"
        ];
        # No auto-format: same as heex.
        language-servers = [ "elixir-ls" ];
      }
      {
        name = "zig";
        roots = [
          "build.zig"
          "build.zig.zon"
          "MODULE.bazel"
          "WORKSPACE"
          "WORKSPACE.bazel"
          ".git"
        ];
        auto-format = true;
        formatter.command = "zig";
        formatter.args = [
          "fmt"
          "--stdin"
        ];
        language-servers = [ "zls" ];
      }
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
        name = "python";
        roots = [
          "pyproject.toml"
          "setup.cfg"
          "setup.py"
          "requirements.txt"
        ];
        auto-format = true;
        formatter = {
          command = "ruff";
          args = [
            "format"
            "-"
          ];
        };
        language-servers = [
          "ty"
          "ruff"
          "pylsp"
          "jedi"
        ];
        debugger = {
          name = "debugpy";
          transport = "stdio";
          command = "python";
          args = [
            "-m"
            "debugpy.adapter"
          ];
          templates = [
            {
              name = "source";
              request = "launch";
              completion = [
                {
                  name = "entrypoint";
                  completion = "filename";
                  default = ".";
                }
              ];
              args = {
                mode = "debug";
                program = "{0}";
              };
            }
          ];
        };
      }
      {
        name = "javascript";
        auto-format = true;
        formatter = prettierFormatter "babel";
        language-servers = [ "typescript-language-server" ];
        debugger = jsDebugger;
      }
      {
        name = "jsx";
        auto-format = true;
        formatter = prettierFormatter "babel";
        language-servers = [ "typescript-language-server" ];
        debugger = jsDebugger;
      }
      {
        name = "typescript";
        auto-format = true;
        formatter = prettierFormatter "typescript";
        language-servers = [ "typescript-language-server" ];
        debugger = jsDebugger;
      }
      {
        name = "tsx";
        auto-format = true;
        formatter = prettierFormatter "typescript";
        language-servers = [ "typescript-language-server" ];
        debugger = jsDebugger;
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

    # ElixirLS may be busy compiling native dependencies on its initial build.
    # Give navigation requests enough time to complete and avoid dependency
    # fetching races between the editor and the project's Mix workflow.
    languages.language-server.elixir-ls = {
      command = lib.getExe elixirLs;
      timeout = 120;
      config.elixirLS = {
        dialyzerEnabled = false;
        fetchDeps = false;
      };
    };

    languages.language-server.zls = {
      command = lib.getExe pkgs.bash;
      args = [
        "-c"
        ''exec "''${ZLS_CMD:-zls}"''
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
