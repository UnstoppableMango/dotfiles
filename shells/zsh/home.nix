# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
{ pkgs, ... }:
{
  imports = [ ./prezto/home.nix ];

  config.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      expireDuplicatesFirst = true;
    };

    initContent = "source ~/.p10k.zsh";
  };
}
