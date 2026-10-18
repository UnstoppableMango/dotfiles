{ lib, config, ... }:
let
  cfg = config.dotfiles.hyprland;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.waybar = {
          enable = true;
          systemd.enable = true;
          # Waybar 0.15.0's resources/config.jsonc with its sway/* modules swapped
          # for the hyprland/* ones, and the modules that need a script or daemon
          # nothing here installs (mpd, custom/media, custom/power,
          # power-profiles-daemon, sway/scratchpad, the second battery) dropped.
          settings.main = lib.mapAttrs (_: lib.mkDefault) (lib.importJSON ./waybar.json);
        };
      }

      (lib.mkIf config.dotfiles.stylix.enable {
        stylix.targets.waybar.enable = true;
      })
    ]
  );
}
