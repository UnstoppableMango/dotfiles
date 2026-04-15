{ config, ... }:
let
  homeModules = config.flake.modules.homeManager;
in
{
  imports = [ ./prezto ];

  flake.modules.homeManager.zsh =
    {
      pkgs,
      lib,
      ...
    }:
    let
      portableShell = import ../bash { inherit lib; };
    in
    {
      imports = with homeModules; [ prezto ];

      home.shell = {
        enableZshIntegration = true;
      };

      home.packages = with pkgs; [
        nix-zsh-completions
        zsh-nix-shell
        zsh-powerlevel10k
      ];

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = portableShell.shellAliases;

        history = {
          append = true;
          expireDuplicatesFirst = true;
          findNoDups = true;
          ignoreDups = true;
          share = true;
        };
      };
    };
}
