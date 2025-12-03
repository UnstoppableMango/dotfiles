{ ... }:
{
  home.file = {
    ".p10k.zsh".source = ../.p10k.zsh;
  };

  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.prezto
  programs.zsh = {
    initContent = ''
      source ~/.p10k.zsh
    '';

    prezto = {
      enable = true;
      caseSensitive = true;
      prompt.theme = "powerlevel10k";

      # https://github.com/sorin-ionescu/prezto/issues/205#issuecomment-314538861
      utility.safeOps = false;
    };
  };
}
