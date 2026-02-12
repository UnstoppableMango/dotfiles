{
  flake.modules.homeManager.vscode-hades =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.vscode.profiles.VMX00505 = {
        userSettings = lib.importJSON ./settings.json;

        extensions = with pkgs.vscode-marketplace; [
          alefragnani.project-manager
          be5invis.vscode-icontheme-nomo-dark
          docker.docker
          editorconfig.editorconfig
          foxundermoon.shell-format
          github.vscode-github-actions
          golang.go
          hashicorp.terraform
          mkhl.direnv
          ms-azuretools.vscode-containers
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          redhat.vscode-yaml
          tamasfe.even-better-toml
          timonwong.shellcheck
          tim-koehler.helm-intellisense
          weaveworks.vscode-gitops-tools
          yzhang.markdown-all-in-one
        ];
      };
    };
}
