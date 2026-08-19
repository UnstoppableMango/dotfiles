{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./prezto
    ./oh-my-zsh
  ];

  options.dotfiles.zsh.enable = lib.mkEnableOption "zsh";

  options.dotfiles.zsh.font = lib.mkOption {
    type = lib.types.str;
    default = "MesloLGS NF";
    description = "Nerd Font family required by Powerlevel10k; also used by terminal emulators.";
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(config.dotfiles.zsh.enable && config.dotfiles.zsh.ohMyZsh.enable);
          message = "dotfiles.zsh.enable (prezto) and dotfiles.zsh.ohMyZsh.enable are mutually exclusive zsh frameworks; enable only one.";
        }
      ];
    }
    (lib.mkIf config.dotfiles.zsh.enable {
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
        historySubstringSearch.enable = true;

        shellAliases = {
          gadd = "git add .";
          gcm = "git commit --message";
          p = "pulumi";
          pp = "pulumi preview";
          ppd = "pulumi preview --diff";
          pd = "pulumi destroy";
          pup = "pulumi up --yes --skip-preview";
          k = "kubectl";
        };

        history = {
          append = true;
          expireDuplicatesFirst = true;
          findNoDups = true;
          ignoreDups = true;
          share = true;
        };
      };
    })
  ];
}
