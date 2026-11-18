{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # Claude Desktop forks link opening from inside its own FHS sandbox, whose
  # /usr holds the env's closure and nothing of the host's. Where the default
  # browser lives in /usr rather than /nix, every PATH lookup for xdg-open ends
  # in ENOENT, and exec'ing the browser directly cannot work either: without
  # /usr/lib/x86_64-linux-gnu the dynamic loader exits 127. The session bus is
  # bind-mounted in, so hand the URL to the desktop portal, which runs outside
  # the sandbox and opens it with the host's own default-browser setting.
  portalOpener = pkgs.writeShellScriptBin "xdg-open" ''
    exec ${lib.getExe' pkgs.glib "gdbus"} call --session \
      --dest org.freedesktop.portal.Desktop \
      --object-path /org/freedesktop/portal/desktop \
      --method org.freedesktop.portal.OpenURI.OpenURI \
      "" "$1" "{}"
  '';

  # targetPkgs is a fixed list with no extraPkgs argument to override, but
  # buildFHSEnv is itself an argument, so wrapping it appends to that list.
  # The opener lands at /usr/bin/xdg-open inside the env, which the sandboxed
  # PATH reaches before either Nix profile.
  withPortalOpener =
    package:
    package.override {
      buildFHSEnv =
        args:
        pkgs.buildFHSEnv (
          args
          // {
            targetPkgs = p: args.targetPkgs p ++ [ portalOpener ];
          }
        );
    };
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

    portalOpener = lib.mkOption {
      type = lib.types.bool;
      default = config.targets.genericLinux.enable;
      defaultText = lib.literalExpression "config.targets.genericLinux.enable";
      description = ''
        Add an `xdg-open` inside the FHS environment that opens URLs through
        the `org.freedesktop.portal.OpenURI` portal. Without it, clicking a
        link in the app silently does nothing on a host whose browser lives
        outside the Nix store, since the sandbox can neither find the real
        xdg-open nor load that browser's libraries.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.claudeDesktop.enable && cfg.claudeDesktop.package != null) {
    home.packages = [
      (
        if cfg.claudeDesktop.portalOpener then
          withPortalOpener cfg.claudeDesktop.package
        else
          cfg.claudeDesktop.package
      )
    ];
  };
}
