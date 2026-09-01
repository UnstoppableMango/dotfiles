{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  cfg = config.dotfiles.darwin.launchServices;
  copyApps = config.targets.darwin.copyApps;
  linkApps = config.targets.darwin.linkApps;

  appsDirectory = if copyApps.enable then copyApps.directory else linkApps.directory;

  lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister";
in
{
  options.dotfiles.darwin.launchServices = {
    enable =
      lib.mkEnableOption "registering Home Manager's macOS apps with Launch Services and Spotlight"
      // {
        default = isDarwin;
        defaultText = lib.literalExpression "pkgs.stdenv.hostPlatform.isDarwin";
      };
  };

  config = lib.mkIf (cfg.enable && isDarwin) {
    # Home Manager drops app bundles into ~/Applications/Home Manager Apps but
    # tells neither Launch Services nor Spotlight about them. Launch Services
    # backs `open -a`, the Dock, and Launchpad; Spotlight's metadata index backs
    # Cmd+Space. rsync writes the bundles with normalized timestamps and no
    # mtime updates, so the fsevents that would normally trigger an automatic
    # reindex do not reliably fire, and an app can sit on disk fully installed
    # yet unreachable from every launcher. Registering explicitly on activation
    # closes that gap.
    home.activation.registerDarwinApps =
      lib.hm.dag.entryAfter ([ "linkGeneration" ] ++ lib.optional copyApps.enable "copyApps")
        ''
          appsDirectory="''${HOME}/${appsDirectory}"

          if [[ -d "$appsDirectory" ]]; then
            # Both tools only refresh an index, so a failure costs a launcher
            # entry rather than a broken generation. Never fail activation.
            run ${lsregister} -f -R "$appsDirectory" || \
              warnEcho "failed to register apps with Launch Services"
            run /usr/bin/mdimport "$appsDirectory" || \
              warnEcho "failed to import apps into the Spotlight index"
          fi
        '';
  };
}
