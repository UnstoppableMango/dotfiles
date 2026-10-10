{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.i3;
  stylix = config.dotfiles.stylix.enable;
  colors = config.lib.stylix.colors.withHashtag;
  mod = "Mod4";

  # GNOME also reaches graphical-session.target; only ~/.hm-xsession starts this one.
  sessionTarget = "hm-graphical-session.target";
  sessionUnits = [
    "picom"
    "polkit-gnome"
  ]
  ++ lib.optional cfg.applets "network-manager-applet"
  ++ lib.optionals cfg.lock.enable [
    "xss-lock"
    "xautolock-session"
  ]
  ++ lib.optional cfg.gnome.enable "xsettingsd";

  # GNOME's appearance as home/ declares it; xsettingsd serves it to GTK apps here.
  gnomeInterface = lib.filterAttrs (_: builtins.isString) (
    config.dconf.settings."org/gnome/desktop/interface" or { }
  );

  rofi = lib.getExe config.programs.rofi.finalPackage;
  exec = cmd: "exec --no-startup-id ${cmd}";

  powerMenu = pkgs.writeShellScript "i3-power-menu" ''
    choice=$(printf '%s\n' Lock "Log out" Suspend Reboot "Shut down" | ${rofi} -dmenu -i -no-custom -p Power)
    case "$choice" in
      Lock) loginctl lock-session ;;
      "Log out") ${config.xsession.windowManager.i3.package}/bin/i3-msg exit ;;
      Suspend) systemctl suspend ;;
      Reboot) systemctl reboot ;;
      "Shut down") systemctl poweroff ;;
    esac
  '';

  # Habits carried over from GNOME and KDE; `does` labels the Super+/ cheat sheet.
  familiar = {
    "${mod}+a" = {
      run = exec "${rofi} -show drun";
      does = "Apps";
    };
    "${mod}+d" = {
      run = exec "${rofi} -show drun";
      does = "Apps";
    };
    "Mod1+Tab" = {
      run = exec "${rofi} -show window";
      does = "Switch windows";
    };
    "${mod}+Tab" = {
      run = exec "${rofi} -show window";
      does = "Switch windows";
    };
    "Mod1+F4" = {
      run = "kill";
      does = "Close window";
    };
    "${mod}+q" = {
      run = "kill";
      does = "Close window";
    };
    "Print" = {
      run = exec "${lib.getExe pkgs.flameshot} gui";
      does = "Screenshot";
    };
    "${mod}+Prior" = {
      run = "workspace prev";
      does = "Previous workspace";
    };
    "${mod}+Next" = {
      run = "workspace next";
      does = "Next workspace";
    };
    "${mod}+Shift+Prior" = {
      run = "move container to workspace prev; workspace prev";
      does = "Move window to previous workspace";
    };
    "${mod}+Shift+Next" = {
      run = "move container to workspace next; workspace next";
      does = "Move window to next workspace";
    };
    "Control+Mod1+Delete" = {
      run = exec "${powerMenu}";
      does = "Power menu";
    };
    "${mod}+Shift+e" = {
      run = exec "${powerMenu}";
      does = "Power menu";
    };
    "${mod}+o" = {
      run = "layout toggle split";
      does = "Toggle split direction";
    };
    "${mod}+p" = {
      run = "focus parent";
      does = "Focus parent container";
    };
    "${mod}+slash" = {
      run = exec "${rofi} -dmenu -i -no-custom -p Keys < ${cheatSheet}";
      does = "This cheat sheet";
    };
  }
  // lib.optionalAttrs cfg.lock.enable {
    "${mod}+l" = {
      run = exec "loginctl lock-session";
      does = "Lock screen";
    };
  }
  // lib.optionalAttrs cfg.gnome.enable {
    "${mod}+e" = {
      run = exec (lib.getExe pkgs.nautilus);
      does = "Files";
    };
    "${mod}+i" = {
      run = exec "env XDG_CURRENT_DESKTOP=GNOME ${lib.getExe pkgs.gnome-control-center}";
      does = "Settings";
    };
  };

  # HM's i3 defaults, which the familiar set leaves alone.
  defaults = {
    "Super+Return" = "Terminal";
    "Super+1..0" = "Go to workspace";
    "Super+Shift+1..0" = "Move window to workspace";
    "Super+Arrows" = "Focus";
    "Super+Shift+Arrows" = "Move window";
    "Super+f" = "Fullscreen";
    "Super+Shift+space" = "Float or tile";
    "Super+h / v" = "Split horizontal / vertical";
    "Super+w / s" = "Tabbed / stacked layout";
    "Super+r" = "Resize mode";
  };

  keyName = lib.replaceStrings [ "Mod4" "Mod1" "Prior" "Next" ] [ "Super" "Alt" "PageUp" "PageDown" ];
  line = key: does: "${key}${lib.fixedWidthString (28 - lib.stringLength key) " " ""}${does}";
  cheatSheet = pkgs.writeText "i3-keys" (
    lib.concatLines (
      lib.mapAttrsToList (k: b: line (keyName k) b.does) familiar ++ lib.mapAttrsToList line defaults
    )
  );

  media = {
    "XF86AudioRaiseVolume" = exec "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
    "XF86AudioLowerVolume" = exec "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
    "XF86AudioMute" = exec "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
    "XF86AudioMicMute" = exec "${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
    "XF86AudioPlay" = exec "${lib.getExe pkgs.playerctl} play-pause";
    "XF86AudioNext" = exec "${lib.getExe pkgs.playerctl} next";
    "XF86AudioPrev" = exec "${lib.getExe pkgs.playerctl} previous";
    "XF86MonBrightnessUp" = exec "${lib.getExe pkgs.brightnessctl} set 5%+";
    "XF86MonBrightnessDown" = exec "${lib.getExe pkgs.brightnessctl} set 5%-";
  };

  lockCmd =
    "${lib.getExe pkgs.i3lock-color} --nofork --clock --time-str='%-I:%M %p' --date-str='%A, %B %-d'"
    + lib.optionalString stylix (
      with config.lib.stylix.colors;
      " --color=${base00} --inside-color=${base01}ff --ring-color=${base0D}ff"
      + " --keyhl-color=${base0E}ff --bshl-color=${base08}ff --line-color=00000000"
      + " --insidever-color=${base01}ff --ringver-color=${base0B}ff"
      + " --insidewrong-color=${base01}ff --ringwrong-color=${base08}ff"
      + " --time-color=${base05}ff --date-color=${base05}ff --verif-color=${base05}ff --wrong-color=${base05}ff"
    );

  background =
    if cfg.wallpaper != null then
      "${lib.getExe pkgs.feh} --no-fehbg --bg-fill ${cfg.wallpaper}"
    else
      "${lib.getExe pkgs.xsetroot} -solid '${if stylix then colors.base00 else "#0a0a0a"}'";
in
{
  options.dotfiles.i3 = {
    enable = lib.mkEnableOption "an i3 X session, chosen at the login screen alongside GNOME";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
      description = "Command Super+Return runs.";
    };

    wallpaper = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Background image; null paints the theme's base color.";
    };

    gnome.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.dotfiles.gnome.enable;
      defaultText = lib.literalExpression "config.dotfiles.gnome.enable";
      description = ''
        Reuse GNOME's pieces: GNOME's dconf appearance served over XSETTINGS
        so GTK apps match, Super+I for GNOME Settings, Super+E for Files, and
        the gtk portal.
      '';
    };

    familiarKeys = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "GNOME/KDE-style bindings (Alt+Tab, Super+A, Print, Ctrl+Alt+Delete), listed by Super+/.";
    };

    applets = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "NetworkManager applet in the tray.";
    };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run ~/.config/autostart entries, as GNOME does.";
    };

    lock.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Lock on idle, on suspend, and on Super+L.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        xsession = {
          enable = true;
          # Off the default names, which the NixOS session wrapper sources for any X login.
          scriptPath = ".hm-xsession";
          profilePath = ".hm-xprofile";
          importedVariables = [ "XDG_CURRENT_DESKTOP" ];
          profileExtra = ''
            export XDG_CURRENT_DESKTOP=i3
            systemctl --user import-environment XDG_CURRENT_DESKTOP
          '';

          windowManager.i3 = {
            enable = true;
            config = {
              modifier = mod;
              inherit (cfg) terminal;
              menu = "${rofi} -show drun";

              keybindings = lib.mkOptionDefault (
                lib.mapAttrs (_: lib.mkDefault) (
                  media // lib.optionalAttrs cfg.familiarKeys (lib.mapAttrs (_: b: b.run) familiar)
                )
              );

              gaps = {
                inner = 8;
                outer = 4;
                smartGaps = true;
              };
              window = {
                titlebar = false;
                border = 2;
                hideEdgeBorders = "smart";
              };
              floating = {
                titlebar = false;
                border = 2;
                criteria = [
                  { class = "(?i)pavucontrol"; }
                  { class = "(?i)gnome-calculator"; }
                  { window_role = "pop-up"; }
                ];
              };
              focus = {
                followMouse = false;
                mouseWarping = false;
              };
              workspaceAutoBackAndForth = true;

              startup = [
                {
                  command = background;
                  always = true;
                  notification = false;
                }
              ]
              ++ lib.optional cfg.autostart {
                command = "${lib.getExe pkgs.dex} --autostart --environment i3";
                notification = false;
              };

              bars = [
                (
                  config.stylix.targets.i3.exportedBarConfig
                  // {
                    position = "top";
                    trayOutput = "primary";
                    statusCommand = "${lib.getExe config.programs.i3status-rust.package} ${config.xdg.configHome}/i3status-rust/config-default.toml";
                    fonts = {
                      names = [ config.dotfiles.zsh.font ];
                      size = 10.0;
                    };
                  }
                )
              ];
            };
          };
        };

        programs.i3status-rust = {
          enable = true;
          bars.default = {
            icons = "material-nf";
            settings.theme = {
              theme = "ctp-mocha";
              overrides = lib.mkIf stylix config.lib.stylix.i3status-rust.bar;
            };
            blocks = lib.mkMerge [
              [
                { block = "net"; }
                { block = "cpu"; }
                { block = "memory"; }
                {
                  block = "disk_space";
                  path = "/";
                }
                { block = "sound"; }
              ]
              (lib.mkAfter [
                {
                  block = "time";
                  interval = 30;
                  format = " $timestamp.datetime(f:'%a %b %-d  %-I:%M %p') ";
                }
              ])
            ];
          };
        };

        programs.rofi = {
          enable = true;
          theme = lib.mkDefault "Arc-Dark";
          settings = {
            inherit (cfg) terminal;
            modi = "drun,run,window";
            show-icons = true;
            icon-theme = "Papirus-Dark";
            display-drun = "Apps";
            display-window = "Windows";
            drun-display-format = "{name}";
          };
        };

        services.dunst = {
          enable = true;
          iconTheme = {
            package = lib.mkDefault pkgs.papirus-icon-theme;
            name = lib.mkDefault "Papirus-Dark";
          };
          settings.global = {
            origin = "top-right";
            offset = "(12, 40)";
            corner_radius = 10;
            frame_width = 2;
            gap_size = 6;
            padding = 10;
            horizontal_padding = 12;
          };
        };

        services.picom = {
          enable = true;
          backend = "glx";
          vSync = true;
          fade = true;
          fadeDelta = 4;
          shadow = true;
          shadowOpacity = 0.35;
          shadowExclude = [ "window_type = 'dock'" ];
          inactiveOpacity = 0.95;
          settings = {
            corner-radius = 10;
            shadow-radius = 14;
            rounded-corners-exclude = [ "window_type = 'dock'" ];
          };
        };

        services.polkit-gnome.enable = true;
        services.network-manager-applet.enable = cfg.applets;

        services.screen-locker = lib.mkIf cfg.lock.enable {
          enable = true;
          inactiveInterval = 10;
          inherit lockCmd;
        };

        home.packages = [ pkgs.flameshot ];

        systemd.user.services = lib.genAttrs sessionUnits (_: {
          Unit.PartOf = lib.mkForce [ sessionTarget ];
          Install.WantedBy = lib.mkForce [ sessionTarget ];
        });
      }

      (lib.mkIf cfg.gnome.enable {
        # gsd-xsettings serves only mutter's Xwayland, so it cannot run under i3.
        services.xsettingsd = {
          enable = true;
          settings = lib.filterAttrs (_: v: v != null) {
            "Net/ThemeName" =
              gnomeInterface."gtk-theme"
                or (if gnomeInterface."color-scheme" or "" == "prefer-dark" then "Adwaita-dark" else null);
            "Net/IconThemeName" = gnomeInterface."icon-theme" or null;
            "Gtk/CursorThemeName" = gnomeInterface."cursor-theme" or null;
            "Gtk/FontName" = gnomeInterface."font-name" or null;
            "Gtk/MonospaceFontName" = gnomeInterface."monospace-font-name" or null;
          };
        };

        xsession.profileExtra = lib.mkIf (gnomeInterface ? "cursor-theme") ''
          export XCURSOR_THEME=${gnomeInterface."cursor-theme"}
        '';

        xdg.configFile."xdg-desktop-portal/i3-portals.conf".text = ''
          [preferred]
          default=gtk
        '';
      })

      (lib.mkIf stylix {
        stylix.targets = {
          i3.enable = true;
          rofi.enable = true;
          dunst.enable = true;
        };
      })
    ]
  );
}
