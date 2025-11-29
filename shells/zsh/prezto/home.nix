{ ... }:
{
  home.file = {
    ".p10k.zsh".source = ../.p10k.zsh;
  };

  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.prezto
  programs.zsh.prezto = {
    enable = true;
    caseSensitive = true;
    color = true;

    extraModules = [ ];
    pmodules = [ ];
    prompt.theme = "powerlevel10k";
  };
}
