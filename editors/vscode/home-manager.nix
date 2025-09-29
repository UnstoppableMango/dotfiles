{ pkgs, ... }:
{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
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

    profiles.UnstoppableMango = {
      extensions =
        with pkgs.vscode-extensions;
        [
          mkhl.direnv
          yzhang.markdown-all-in-one
          dbaeumer.vscode-eslint
          eamodio.gitlens
          ms-vscode-remote.vscode-remote-extensionpack
          github.vscode-github-actions
          editorconfig.editorconfig

          redhat.vscode-yaml
          tamasfe.even-better-toml
          jnoortheen.nix-ide
          ziglang.vscode-zig
          zxh404.vscode-proto3
          golang.go
          ms-dotnettools.csharp
          ms-dotnettools.csdevkit
          ionide.ionide-fsharp
          # ionide.ionide-fake
          rust-lang.rust-analyzer
          ocamllabs.ocaml-platform
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
          apollographql.vscode-apollo

          # TODO
          # mogeko.haskell-extension-pack
          haskell.haskell

          # TODO: Swap these around
          ms-azuretools.vscode-docker
          # docker.docker
          # ms-azuretools.vscode-containers

          ms-kubernetes-tools.vscode-kubernetes-tools
          # weaveworks.vscode-gitops-tools # TODO
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-icontheme-nomo-dark";
            publisher = "be5invis";
            version = "1.3.7";
            sha256 = "sha256-WdRUvM5KUXU8I8/6TIkhugwgV4ECbLXnAt+LlaenvLU=";
          }
        ];

      userSettings = {
        terminal.integrated.fontFamily = "MesloLGS NF";
        workbench.iconTheme = "vs-nomo-dark";
      };
    };
  };
}
