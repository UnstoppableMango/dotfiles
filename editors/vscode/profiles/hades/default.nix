{ self, ... }:
{
  flake.modules.homeManager.vscode-hades =
    {
      pkgs,
      lib,
      ...
    }:
    {
      nixpkgs.overlays = [ self.overlays.vscodeExtensions ];

      programs.vscode.profiles.Hades = {
        # https://github.com/microsoft/vscode-dotnettools/issues/2266#issuecomment-3571804122
        userSettings = lib.importJSON ./settings.json;

        extensions = with pkgs.vscode-marketplace; [
          mkhl.direnv
          yzhang.markdown-all-in-one
          dbaeumer.vscode-eslint
          eamodio.gitlens
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          github.vscode-github-actions
          github.copilot
          anthropic.claude-code
          hashicorp.terraform
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
          haskell.haskell
          ms-kubernetes-tools.vscode-kubernetes-tools
          be5invis.vscode-icontheme-nomo-dark
          ionide.ionide-fake
          docker.docker
          weaveworks.vscode-gitops-tools
          alefragnani.project-manager
          bufbuild.vscode-buf
          dprint.dprint
          timonwong.shellcheck
          ms-azuretools.vscode-containers
          tim-koehler.helm-intellisense
          foxundermoon.shell-format
          jetbrains.resharper-code
          oven.bun-vscode
        ];
      };
    };
}
