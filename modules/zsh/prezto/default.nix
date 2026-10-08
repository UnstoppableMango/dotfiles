{ lib, config, ... }:
let
  cfg = config.dotfiles.zsh;
in
{
  options.dotfiles.zsh.prezto.enable = lib.mkEnableOption "prezto";

  config = lib.mkIf (cfg.enable && cfg.prezto.enable) {
    programs.zsh = {
      initContent = ''
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
