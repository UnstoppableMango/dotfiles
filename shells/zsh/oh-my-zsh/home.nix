# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
{ pkgs, ... }:
{
  config.programs.zsh = {
    enable = true;
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
