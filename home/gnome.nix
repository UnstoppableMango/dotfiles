{ lib, config, ... }:
{
  # Taste only. The option, the extension packages, and keeping the enabled
  # list in step with them live in modules/desktop/gnome.
  config = lib.mkIf config.dotfiles.gnome.enable {
    dconf.settings = {
      "org/freedesktop/ibus/panel/emoji" = {
        # Disable ctrl+shift+u unicode shortcut, conflicts with JetBrains keybinds
        # https://superuser.com/questions/358749/how-to-disable-ctrlshiftu/1392682#1392682
        unicode-hotkey = "@as []";
      };

      # dconf dump / > tmp.dconf
      "org/gnome/desktop/interface" = {
        accent-color = "pink";
        clock-format = "12h";
        clock-show-seconds = false;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        cursor-theme = "breeze_cursors";
        enable-hot-corners = false;
        icon-theme = "Papirus";
        monospace-font-name = "FiraCode Nerd Font Mono 11";
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        autohide = false;
        custom-background-color = false;
        custom-theme-shrink = true;
        dash-max-icon-size = 48;
        dock-fixed = true;
        dock-position = "RIGHT";
        extend-height = true;
        intellihide = false;
        running-indicator-dominant-color = false;
        running-indicator-style = "DOTS";
        show-show-apps-button = true; # This is not a typo
        show-trash = false;
        unity-backlit-items = false;
        click-action = "cycle-windows";
      };
    };
  };
}
