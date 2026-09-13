{ lib, config, ... }:
let
  cfg = config.dotfiles.zsh;
in
{
  options.dotfiles.zsh.ohMyZsh.enable = lib.mkEnableOption "oh-my-zsh";

  # The prompt is Powerlevel10k, sourced from ../default.nix, so `theme` stays unset.
  config = lib.mkIf (cfg.enable && cfg.ohMyZsh.enable) {
    programs.zsh.oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"

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
    };
  };
}
