{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  json = pkgs.formats.json { };
in
{
  imports = [ ./opencode.nix ];

  options.dotfiles.ai = {
    enable = lib.mkEnableOption "slop";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      context = ./global-context.md;
    };

    programs.github-copilot-cli = {
      enable = true;
      context = ./global-context.md;
    };

    home.packages = with pkgs; [ cursor-cli ];

    xdg.configFile."caveman/config.json".source = json.generate "caveman-config.json" {
      defaultMode = "off";
    };
  };
}
