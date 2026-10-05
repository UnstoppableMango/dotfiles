{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
in
{
  options.dotfiles.ai.claudeDesktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Install Claude Desktop. Its MCP servers come from claude.ai connectors,
        and the app owns `claude_desktop_config.json`.
      '';
    };

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = if pkgs.stdenv.hostPlatform.isLinux then pkgs.claude-desktop-fhs else null;
      defaultText = lib.literalExpression "if isLinux then pkgs.claude-desktop-fhs else null";
      description = ''
        The Claude Desktop app to install. The FHS variant gives any MCP server
        the app spawns a normal filesystem layout. Null on macOS, where the app
        has no package and is installed by hand.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.claudeDesktop.enable && cfg.claudeDesktop.package != null) {
    home.packages = [ cfg.claudeDesktop.package ];
  };
}
