{ ... }:
{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.prezto
  config.programs.prezto = {
    enable = true;
    caseSensitive = true;
    color = true;

    extraConfig = ''
      zstyle ':prezto:module:prompt' theme 'powerlevel10k'
    '';

    extraModules = [];
    pmodules = [];
    prompt.theme = "powerlevel10k";
  };
}
