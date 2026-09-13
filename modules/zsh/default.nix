{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dotfiles.zsh;
in
{
  imports = [
    ./oh-my-zsh
    ./prezto
  ];

  options.dotfiles.zsh.enable = lib.mkEnableOption "zsh";

  options.dotfiles.zsh.font = lib.mkOption {
    type = lib.types.str;
    default = "MesloLGS NF";
    description = "Nerd Font family required by Powerlevel10k; also used by terminal emulators.";
  };

  options.dotfiles.zsh.p10kConfig = lib.mkOption {
    type = with lib.types; nullOr path;
    default = ./.p10k.zsh;
    defaultText = lib.literalExpression "./.p10k.zsh";
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

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.ohMyZsh.enable && cfg.prezto.enable);
          message = "dotfiles.zsh.ohMyZsh.enable and dotfiles.zsh.prezto.enable are mutually exclusive zsh frameworks; enable only one.";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      home.shell = {
        enableZshIntegration = true;
      };

      home.packages = with pkgs; [
        nix-zsh-completions
        zsh-nix-shell
        zsh-powerlevel10k
      ];

      home.file = lib.mkIf (cfg.p10kConfig != null) {
        ".p10k.zsh".source = cfg.p10kConfig;
      };

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        historySubstringSearch.enable = true;

        # Prezto loads the theme through `prompt.theme`; anything else sources it here.
        initContent =
          lib.optionalString (!cfg.prezto.enable) ''
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          ''
          + lib.optionalString (cfg.p10kConfig != null) ''
            source ~/.p10k.zsh
          '';

        shellAliases = {
          gadd = "git add .";
          gcm = "git commit --message";
          p = "pulumi";
          pp = "pulumi preview";
          ppd = "pulumi preview --diff";
          pd = "pulumi destroy";
          pup = "pulumi up --yes --skip-preview";
          k = "kubectl";
        };

        history = {
          append = true;
          expireDuplicatesFirst = true;
          findNoDups = true;
          ignoreDups = true;
          share = true;
        };
      };
    })
  ];
}
