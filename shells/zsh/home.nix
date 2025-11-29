# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
{ pkgs, ... }:
{
  imports = [ ./prezto/home.nix ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      append = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreDups = true;
      share = false;
    };
  };
}
