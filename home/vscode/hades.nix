{
  pkgs,
  lib,
  ...
}:
{
  config = {
    programs.vscode.profiles.Hades = {
      # https://github.com/microsoft/vscode-dotnettools/issues/2266#issuecomment-3571804122
      # hades.settings.json turns GPU acceleration off for the reason in ./default.nix.
      userSettings = lib.importJSON ./hades.settings.json;
      enableMcpIntegration = true;

      extensions = with pkgs.vscode-marketplace; [
        alefragnani.project-manager
        anthropic.claude-code
        apollographql.vscode-apollo
        be5invis.vscode-icontheme-nomo-dark
        bradlc.vscode-tailwindcss
        bufbuild.vscode-buf
        coderabbit.coderabbit-vscode
        dbaeumer.vscode-eslint
        docker.docker
        dprint.dprint
        eamodio.gitlens
        editorconfig.editorconfig
        foxundermoon.shell-format
        github.vscode-github-actions
        golang.go
        graphql.vscode-graphql
        graphql.vscode-graphql-syntax
        hashicorp.terraform
        haskell.haskell
        humao.rest-client
        ionide.ionide-fake
        ionide.ionide-fsharp
        # vscode-marketplace resolves this to 0.0.2, an expired EAP build whose
        # backend aborts on startup; the release set has a stable one.
        pkgs.vscode-marketplace-release.jetbrains.resharper-code
        jnoortheen.nix-ide
        microsoft-aspire.aspire-vscode
        mkhl.direnv
        ms-azuretools.vscode-containers
        ms-dotnettools.csharp
        # Build fails: a substitution matches nothing in 'dist/extension.js'.
        # ms-dotnettools.csdevkit
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
      ];
    };
  };
}
