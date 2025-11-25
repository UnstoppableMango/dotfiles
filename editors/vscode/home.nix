# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
{ pkgs, ... }:
{
  config = {
    programs.vscode = {
      enable = true;
      haskell = {
        enable = true;

        # TODO: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.haskell.hie.executablePath
        hie.enable = false;
      };

      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
      };

      profiles.Hades = {
        extensions =
          with pkgs.vscode-extensions;
          [
            mkhl.direnv
            yzhang.markdown-all-in-one
            dbaeumer.vscode-eslint
            eamodio.gitlens
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-ssh
            github.vscode-github-actions
            github.copilot
            # anthropic.claude-code
            editorconfig.editorconfig

            redhat.vscode-yaml
            tamasfe.even-better-toml
            jnoortheen.nix-ide
            ziglang.vscode-zig
            zxh404.vscode-proto3
            golang.go
            ms-dotnettools.csharp
            ms-dotnettools.csdevkit
            ms-dotnettools.vscode-dotnet-runtime
            ionide.ionide-fsharp
            rust-lang.rust-analyzer
            ocamllabs.ocaml-platform
            graphql.vscode-graphql
            graphql.vscode-graphql-syntax
            apollographql.vscode-apollo
            myriad-dreamin.tinymist
            bradlc.vscode-tailwindcss

            # TODO
            # mogeko.haskell-extension-pack
            haskell.haskell

            ms-kubernetes-tools.vscode-kubernetes-tools
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "vscode-icontheme-nomo-dark";
              publisher = "be5invis";
              version = "1.3.7";
              sha256 = "sha256-WdRUvM5KUXU8I8/6TIkhugwgV4ECbLXnAt+LlaenvLU=";
            }
            {
              name = "ionide-fake";
              publisher = "ionide";
              version = "1.2.3";
              sha256 = "sha256-SeiW8zHWwaOc+OlRI2jxdIZFhe6eSvb1kDGs2li3T0Y=";
            }
            {
              name = "docker";
              publisher = "docker";
              version = "0.17.0";
              sha256 = "sha256-c1M5pC8JGm+IKQIviE163kYQOX8Nx0Gty7rV7OQCy88=";
            }
            {
              name = "vscode-gitops-tools";
              publisher = "weaveworks";
              version = "0.27.0";
              sha256 = "sha256-7MCKDnHCot/CL/SqZ2WuTxbqFdF75EC5WC+OxW0dcaE=";
            }
            {
              name = "project-manager";
              publisher = "alefragnani";
              version = "12.8.0";
              sha256 = "sha256-sNiDyWdQ40Xeu7zp1ioRCi3majrPshlVbUSV2klr4r4=";
            }
            {
              name = "vscode-buf";
              publisher = "bufbuild";
              version = "0.8.1";
              sha256 = "sha256-pJG1vrx5BmI+60rh+OkeVASDLQPQGNaeAYs/07Va438=";
            }
            {
              name = "dprint";
              publisher = "dprint";
              version = "0.16.7";
              sha256 = "sha256-9o3mEmQ/8XjWnqpTjsVG4iYv1pe71ZRMO11PNmm6z4k=";
            }
            {
              name = "shellcheck";
              publisher = "timonwong";
              version = "0.38.3";
              sha256 = "sha256-qDispRN7jRIIsP+5lamyR+sNoOwTwl+55QftzO7WBm4=";
            }
            {
              name = "vscode-containers";
              publisher = "ms-azuretools";
              version = "2.2.0";
              sha256 = "sha256-UxWsu7AU28plnT0QMdpPJrcYZIV09FeC+rmYKf39a6M=";
            }
            {
              name = "helm-intellisense";
              publisher = "tim-koehler";
              version = "0.15.0";
              sha256 = "sha256-Tl0X2jtgTsjf2tvyAJLGxEGrmLXACYWWErcDJuQYg+o=";
            }
            {
              name = "shell-format";
              publisher = "foxundermoon";
              version = "7.2.8";
              sha256 = "sha256-Z3vmRzqPCxkQbn39I54bh/ND+0HcE9iFUhKQ29GRd7o=";
            }
            {
              name = "resharper-code";
              publisher = "JetBrains";
              version = "0.0.11";
              sha256 = "sha256-UxvwGkefK/b6/sK8WcCis2MWRNkPH/hHAy2BY7GfW70=";
            }
            {
              name = "bun-vscode";
              publisher = "oven";
              version = "0.0.31";
              sha256 = "sha256-KlsXU1UpkxaX1rI16CD0KMhe7aarv8A94ZZ0TxlI5Ns=";
            }
          ];

        userSettings = {
          terminal.integrated.fontFamily = "MesloLGS NF";
          workbench.iconTheme = "vs-nomo-dark";
          redhat.telemetry.enabled = false;
          # https://github.com/alefragnani/vscode-project-manager/blob/master/README.md#available-settings
          projectManager = {
            git = {
              baseFolders = [
                "~/src/github.com/UnstoppableMango"
                "~/src/github.com/unmango"
                "~/src/github.com/pulumiverse"
              ];
            };
            tags = [
              "Personal"
              "Work"
              "FOSS"
            ];
          };
        };
      };
    };
  };
}
