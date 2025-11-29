# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
{
  imports = [ ./prezto/home.nix ];

  home.shell = {
    enableZshIntegration = true;
  };

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
