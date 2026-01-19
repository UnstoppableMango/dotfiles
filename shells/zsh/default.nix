{ config, ... }:
let
  homeModules = config.flake.modules.homeManager;
in
{
  imports = [ ./prezto ];

  flake.modules.homeManager.zsh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
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

        initContent = lib.mkIf config.openshift.enable (
          lib.mkAfter ''
            eval $(crc podman-env)
          ''
        );

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
    };
}
