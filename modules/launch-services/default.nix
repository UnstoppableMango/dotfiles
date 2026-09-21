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
    # rsync's normalized timestamps keep fsevents from triggering a reindex.
    home.activation.registerDarwinApps =
      lib.hm.dag.entryAfter ([ "linkGeneration" ] ++ lib.optional copyApps.enable "copyApps")
        ''
          appsDirectory="''${HOME}/${appsDirectory}"

          if [[ -d "$appsDirectory" ]]; then
            # Only an index refresh, so warn rather than fail activation.
            run ${lsregister} -f -R "$appsDirectory" || \
              warnEcho "failed to register apps with Launch Services"
            run /usr/bin/mdimport "$appsDirectory" || \
              warnEcho "failed to import apps into the Spotlight index"
          fi
        '';
  };
}
