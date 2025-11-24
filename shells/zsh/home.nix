# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
{ pkgs, ... }:
{
  config = {

    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      expireDuplicatesFirst = true;
    };

    initContent = "source ~/.p10k.zsh";
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"
        "ssh-agent"
        "gpg-agent"

        "git"
        "nix-shell"
        "direnv"

        "nvm"
        "npm"
        "yarn"
        "deno"
        "bun"

        "golang"
        "dotnet"

        "kubectl"
        "docker"
        "helm"
      ];

      # This is printing warnings... thought it was required?
      # theme = "powerlevel10k/powerlevel10k";
    };
  };
}
