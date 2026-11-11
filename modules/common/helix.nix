{ pkgs, lib, ... }:

let
  expert =
    let
      version = "0.2.2";
      assets = {
        aarch64-darwin = {
          name = "expert_darwin_arm64";
          hash = "sha256-Bx6glOUAo/Kta387FjRlDWBhsR+O+Yp7/pcmUGMZxYI=";
        };
        x86_64-darwin = {
          name = "expert_darwin_amd64";
          hash = "sha256-d6T/sscOVoHz6N4o0cRX3actXdeCbEPBNIZS6xf+HpE=";
        };
        x86_64-linux = {
          name = "expert_linux_amd64";
          hash = "sha256-Rh21r0afWljXJ2JPJl3L1htFrDFeeQlyijUPu+CcLHA=";
        };
        aarch64-linux = {
          name = "expert_linux_arm64";
          hash = "sha256-hSQJ+e3t9OZTw6/3CKDfyW11etDoe0+/SVbGl+HgX70=";
        };
      };
      asset = assets.${pkgs.stdenv.hostPlatform.system};
      binary = pkgs.fetchurl {
        url = "https://github.com/expert-lsp/expert/releases/download/v${version}/${asset.name}";
        inherit (asset) hash;
      };
    in
    pkgs.runCommand "expert-${version}" { meta.mainProgram = "expert"; } ''
      install -Dm755 ${binary} $out/bin/expert
    '';

  expertShell = pkgs.writeShellScript "expert-shell" ''
    cd "$EXPERT_PROJECT_ROOT" && eval "$(${lib.getExe pkgs.direnv} export bash 2>/dev/null)"
    exec ${lib.getExe pkgs.bash} --noprofile --norc -c "''${@: -1}"
  '';

  expertElixir = pkgs.beamPackages.elixir_1_19.overrideAttrs (old: {
    env = old.env // {
      ERL_COMPILER_OPTIONS = "[debug_info]";
    };
  });

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

    expert

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
        auto-format = true;
        language-servers = [ "expert" ];
      }
      {
        name = "heex";
        roots = [
          "mix.exs"
          ".git"
        ];
        language-servers = [ "expert" ];
      }
      {
        name = "eex";
        roots = [
          "mix.exs"
          ".git"
        ];
        language-servers = [ "expert" ];
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

    languages.language-server.expert = {
      command = lib.getExe expert;
      args = [ "--stdio" ];
      environment.SHELL = "${expertShell}";
      timeout = 120;
      config = {
        elixirExecutablePath = lib.getExe' expertElixir "elixir";
        erlangExecutablePath = lib.getExe' pkgs.beamPackages.erlang "erl";
        elixirSourcePath = "${expertElixir.src}";
      };
    };

    languages.language-server.zls = {
      command = lib.getExe pkgs.bash;
      args = [
        "-c"
        ''exec "''${ZLS_CMD:-zls}"''
      ];
    };

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
      cargo.target = "aarch64-unknown-linux-gnu";
    };

  };
}
