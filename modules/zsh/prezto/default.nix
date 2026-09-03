{ lib, config, ... }:
let
  cfg = config.dotfiles.zsh;
in
{
  options.dotfiles.zsh.p10kConfig = lib.mkOption {
    type = with lib.types; nullOr path;
    default = ./.p10k.zsh;
    defaultText = lib.literalExpression "./prezto/.p10k.zsh";
    description = ''
      Powerlevel10k configuration written to `~/.p10k.zsh` and sourced from
      `programs.zsh.initContent`.

      The bundled file is a default rather than a literal in an identity layer
      because a prompt that renders correctly is a property of the theme and
      the Nerd Font this module already pins, not of the person. Point it at
      your own file to replace it, or set null to write none and configure the
      prompt yourself.

      Regenerate the bundled one with the `p10k` target in the Makefile.
    '';
  };

  config = lib.mkIf cfg.enable {
    home.file = lib.mkIf (cfg.p10kConfig != null) {
      ".p10k.zsh".source = cfg.p10kConfig;
    };

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.prezto
    programs.zsh = {
      initContent =
        lib.optionalString (cfg.p10kConfig != null) ''
          source ~/.p10k.zsh

        ''
        + ''
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
