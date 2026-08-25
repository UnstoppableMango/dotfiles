{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai.omnigent;

  omnigentBin = "${config.home.homeDirectory}/.local/bin/omnigent";

  # No nixpkgs package or Homebrew cask exists for the desktop client, so the
  # .dmg is fetched and unpacked directly. Bump version + sha256 together when
  # updating: https://omnigent.ai/download/mac redirects to the versioned URL.
  omnigent-desktop = pkgs.stdenvNoCC.mkDerivation {
    pname = "omnigent-desktop";
    version = "0.10.0";
    src = pkgs.fetchurl {
      url = "https://diksk5m140cfbma7.public.blob.vercel-storage.com/mac/Omnigent-0.10.0-arm64.dmg";
      sha256 = "sha256-tfSV3R6k8P1Jib6RmCjwxFP/hQBtaBKFPQeisXTDdjU=";
    };
    nativeBuildInputs = [ pkgs.undmg ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/Applications
      cp -pR *.app $out/Applications
    '';
  };
in
{
  options.dotfiles.ai.omnigent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run `omnigent start` as a login service (launchd on macOS, a systemd user unit on Linux) so the local server at localhost:6767 is always up for the desktop, web, and mobile clients to connect to.";
    };

    desktopApp = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isDarwin;
      description = "Install the Omnigent.app native desktop client. macOS (aarch64) only.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      { programs.uv.tool.packages = [ "omnigent" ]; }

      (lib.mkIf (cfg.autostart && pkgs.stdenv.hostPlatform.isDarwin) {
        launchd.agents.omnigent-server = {
          enable = true;
          config = {
            Label = "ai.omnigent.server";
            ProgramArguments = [
              omnigentBin
              "start"
            ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "${config.xdg.dataHome}/omnigent/server.log";
            StandardErrorPath = "${config.xdg.dataHome}/omnigent/server.log";
          };
        };
      })

      (lib.mkIf (cfg.autostart && pkgs.stdenv.hostPlatform.isLinux) {
        systemd.user.services.omnigent-server = {
          Unit.Description = "Omnigent local server";
          Service = {
            ExecStart = "%h/.local/bin/omnigent start";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "default.target" ];
        };
      })

      (lib.mkIf (cfg.desktopApp && pkgs.stdenv.hostPlatform.isDarwin) {
        # Symlinked straight from the nix store, so the bundle carries no
        # quarantine/notarization ticket - first launch needs a right-click >
        # Open to get past Gatekeeper.
        home.file."Applications/Omnigent.app".source = "${omnigent-desktop}/Applications/Omnigent.app";
      })
    ]
  );
}
