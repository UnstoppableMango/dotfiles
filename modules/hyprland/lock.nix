{ lib, config, ... }:
let
  cfg = config.dotfiles.hyprland;
  dpms = action: "hyprctl dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
in
{
  options.dotfiles.hyprland.lock.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "hyprlock, plus hypridle locking, blanking, and suspending on idle.";
  };

  config = lib.mkIf (cfg.enable && cfg.lock.enable) (
    lib.mkMerge [
      {
        # hyprlock's assets/example.conf, less the colors stylix supplies and the
        # en/ru keyboard layout label.
        programs.hyprlock = {
          enable = true;
          settings = {
            "$font" = lib.mkDefault "Monospace";
            general.hide_cursor = lib.mkDefault false;

            animations = {
              enabled = lib.mkDefault true;
              bezier = lib.mkDefault "linear, 1, 1, 0, 0";
              animation = lib.mkDefault [
                "fadeIn, 1, 5, linear"
                "fadeOut, 1, 5, linear"
                "inputFieldDots, 1, 2, linear"
              ];
            };

            background = {
              monitor = "";
              path = lib.mkDefault "screenshot";
              blur_passes = lib.mkDefault 3;
            };

            input-field = {
              monitor = "";
              size = lib.mkDefault "20%, 5%";
              outline_thickness = lib.mkDefault 3;
              fade_on_empty = lib.mkDefault false;
              rounding = lib.mkDefault 15;
              font_family = lib.mkDefault "$font";
              placeholder_text = lib.mkDefault "Input password...";
              fail_text = lib.mkDefault "$PAMFAIL$FPRINTFAIL";
              dots_spacing = lib.mkDefault 0.3;
              position = lib.mkDefault "0, -20";
              halign = lib.mkDefault "center";
              valign = lib.mkDefault "center";
            };

            label = lib.mkDefault [
              {
                monitor = "";
                text = "$TIME";
                font_size = 90;
                font_family = "$font";
                position = "-30, 0";
                halign = "right";
                valign = "top";
              }
              {
                monitor = "";
                text = ''cmd[update:60000] date +"%A, %d %B %Y"'';
                font_size = 25;
                font_family = "$font";
                position = "-30, -150";
                halign = "right";
                valign = "top";
              }
            ];
          };
        };

        # The wiki's full hypridle example, less its backlight listeners: brightnessctl
        # reaches no external monitor, and dpms covers blanking.
        services.hypridle = {
          enable = true;
          settings = {
            general = {
              lock_cmd = "pidof hyprlock || hyprlock";
              before_sleep_cmd = "loginctl lock-session";
              after_sleep_cmd = dpms "enable";
            };

            listener = lib.mkDefault [
              {
                timeout = 300;
                on-timeout = "loginctl lock-session";
              }
              {
                timeout = 330;
                on-timeout = dpms "disable";
                on-resume = dpms "enable";
              }
              {
                timeout = 1800;
                on-timeout = "systemctl suspend";
              }
            ];
          };
        };
      }

      (lib.mkIf config.dotfiles.stylix.enable {
        stylix.targets.hyprlock.enable = true;
      })
    ]
  );
}
