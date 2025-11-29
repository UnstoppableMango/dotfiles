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
    };
  };
}
