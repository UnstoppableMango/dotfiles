{
  flake.modules.homeManager.vscode-hades =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.vscode.profiles.Hades = {
        # https://github.com/microsoft/vscode-dotnettools/issues/2266#issuecomment-3571804122
        userSettings = lib.importJSON ./settings.json;

        extensions = with pkgs.vscode-marketplace; [
          alefragnani.project-manager
          anthropic.claude-code
          apollographql.vscode-apollo
          be5invis.vscode-icontheme-nomo-dark
          bradlc.vscode-tailwindcss
          bufbuild.vscode-buf
          dbaeumer.vscode-eslint
          docker.docker
          dprint.dprint
          eamodio.gitlens
          editorconfig.editorconfig
          foxundermoon.shell-format
          github.vscode-github-actions
          github.copilot
          golang.go
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
          hashicorp.terraform
          haskell.haskell
          ionide.ionide-fake
          ionide.ionide-fsharp
          jetbrains.resharper-code
          jnoortheen.nix-ide
          microsoft-aspire.aspire-vscode
          mkhl.direnv
          ms-azuretools.vscode-containers
          ms-dotnettools.csharp
          ms-dotnettools.csdevkit
          ms-dotnettools.vscode-dotnet-runtime
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          myriad-dreamin.tinymist
          ocamllabs.ocaml-platform
          oven.bun-vscode
          redhat.vscode-yaml
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          timonwong.shellcheck
          tim-koehler.helm-intellisense
          weaveworks.vscode-gitops-tools
          yzhang.markdown-all-in-one
          ziglang.vscode-zig
          zxh404.vscode-proto3
        ];
      };
    };
}
