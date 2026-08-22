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
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      settings = lib.mkIf cfg.openrouter.enable {
        provider.openrouter.options.apiKey = "{env:OPENROUTER_API_KEY}";
      };
    };

    home.packages = with pkgs; [
      opencode-desktop
      opencode-claude-auth
    ];
  };
}
