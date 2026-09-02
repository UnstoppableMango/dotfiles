{ lib, config, ... }:
{
  options.dotfiles.zsh.ohMyZsh.enable = lib.mkEnableOption "oh-my-zsh (alt to prezto)";

  config = lib.mkIf config.dotfiles.zsh.ohMyZsh.enable {
    programs.zsh.oh-my-zsh = {
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
