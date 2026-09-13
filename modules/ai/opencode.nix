{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai.opencode;
in
{
  options.dotfiles.ai.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    openrouter = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "OpenRouter as an opencode model provider. Needs an OPENROUTER_API_KEY exported in the shell. Disabled by default.";
      };
    };

    desktop.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "The opencode desktop app (Electron). Headless hosts turn it off.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = lib.mkIf cfg.openrouter.enable {
        provider.openrouter.options.apiKey = "{env:OPENROUTER_API_KEY}";
      };
    };

    home.packages = [
      pkgs.opencode-claude-auth
    ]
    ++ lib.optional cfg.desktop.enable pkgs.opencode-desktop;
  };
}
