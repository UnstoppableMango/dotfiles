{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.zsh.enable {
    home.file = {
      ".p10k.zsh".source = ../.p10k.zsh;
    };

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.prezto
    programs.zsh = {
      initContent = ''
        source ~/.p10k.zsh

        # Remove prezto autoload stubs that break Claude Code shell snapshots.
        # See: https://github.com/anthropics/claude-code/issues/1849
        for _f in ''${(k)functions}; do
          [[ ''${functions[$_f]} == *'builtin autoload -XUz'* ]] && unfunction -- $_f
        done
        unset _f
      '';

      prezto = {
        enable = true;
        caseSensitive = true;
        prompt.theme = "powerlevel10k";

        # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.prezto.pmodules
        pmodules = [
          # Default
          "environment"
          "terminal"
          "editor"
          "history"
          "directory"
          "spectrum"
          "utility"
          "completion"
          "prompt"

          # Custom
          "history-substring-search"
        ];

        # https://github.com/sorin-ionescu/prezto/issues/205#issuecomment-314538861
        utility.safeOps = false;
      };
    };
  };
}
