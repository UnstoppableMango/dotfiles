{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.automation.flakeUpdate;
in
{
  options.dotfiles.automation.flakeUpdate = {
    enable = lib.mkEnableOption "periodic `nix flake update` + `home-manager switch` via a systemd user timer (Linux only)";

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "%h/.config/home-manager";
      description = "Path (systemd specifiers like %h allowed) to the flake to update and switch.";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "weekly";
      description = "systemd OnCalendar expression for the update timer.";
    };
  };

  # home-manager's systemd.user.* options are Linux-only.
  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    systemd.user.services.flake-update = {
      Unit.Description = "Update flake inputs and switch home-manager";
      Service = {
        Type = "oneshot";
        ExecStart = toString (
          pkgs.writeShellScript "flake-update" ''
            set -eu
            cd ${cfg.flakePath}
            ${lib.getExe pkgs.nix} flake update
            ${pkgs.home-manager}/bin/home-manager switch --flake ${cfg.flakePath}
          ''
        );
      };
    };

    systemd.user.timers.flake-update = {
      Unit.Description = "Timer for flake-update.service";
      Timer = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
