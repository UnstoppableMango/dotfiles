{ pkgs, ... }:
{
  imports = [ ./prezto/home.nix ];

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

    history = {
      append = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreDups = true;
      share = false;
    };
  };
}
