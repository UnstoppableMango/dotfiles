{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.hyprland;
  inherit (lib.generators) mkLuaInline;

  # One `hl.bind(...)` call; `dsp` is the Lua dispatcher expression.
  bind = key: dsp: opts: {
    _args = [
      key
      (mkLuaInline dsp)
    ]
    ++ lib.optional (opts != { }) opts;
  };
  exec = cmd: "hl.dsp.exec_cmd(${lib.generators.toLua { } cmd})";
  media = {
    locked = true;
    repeating = true;
  };

  workspaceBinds = lib.concatMap (
    i:
    let
      key = toString (lib.mod i 10);
    in
    [
      (bind "SUPER + ${key}" "hl.dsp.focus({ workspace = ${toString i} })" { })
      (bind "SUPER + SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString i} })" { })
    ]
  ) (lib.range 1 10);
in
{
  imports = [
    ./lock.nix
    ./waybar.nix
  ];

  options.dotfiles.hyprland = {
    enable = lib.mkEnableOption "a Hyprland session, chosen at the login screen alongside GNOME and i3";

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "kitty";
      description = "Command Super+Q runs.";
    };

    fileManager = lib.mkOption {
      type = lib.types.str;
      default = "nautilus";
      description = "Command Super+E runs.";
    };

    menu = lib.mkOption {
      type = lib.types.str;
      default = "hyprlauncher";
      description = "Command Super+R runs.";
    };

    wallpaper = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Background image for hyprpaper; null keeps Hyprland's own default wallpaper.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        wayland.windowManager.hyprland = {
          enable = true;
          # The system's programs.hyprland owns the package, the session entry, and the portal.
          package = null;
          portalPackage = null;
          configType = "lua";

          # Hyprland's own example/hyprland.lua, less the colors stylix supplies.
          settings = {
            monitor = lib.mkDefault {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = "auto";
            };

            env = [
              {
                _args = [
                  "XCURSOR_SIZE"
                  "24"
                ];
              }
              {
                _args = [
                  "HYPRCURSOR_SIZE"
                  "24"
                ];
              }
            ];

            config = {
              general = {
                gaps_in = lib.mkDefault 5;
                gaps_out = lib.mkDefault 20;
                border_size = lib.mkDefault 2;
                resize_on_border = lib.mkDefault false;
                allow_tearing = lib.mkDefault false;
                layout = lib.mkDefault "dwindle";
              };

              decoration = {
                rounding = lib.mkDefault 10;
                rounding_power = lib.mkDefault 2;
                active_opacity = lib.mkDefault 1.0;
                inactive_opacity = lib.mkDefault 1.0;
                shadow = {
                  enabled = lib.mkDefault true;
                  range = lib.mkDefault 4;
                  render_power = lib.mkDefault 3;
                };
                blur = {
                  enabled = lib.mkDefault true;
                  size = lib.mkDefault 3;
                  passes = lib.mkDefault 1;
                  vibrancy = lib.mkDefault 0.1696;
                };
              };

              animations.enabled = lib.mkDefault true;
              dwindle.preserve_split = lib.mkDefault true;
              master.new_status = lib.mkDefault "master";
              scrolling.fullscreen_on_one_column = lib.mkDefault true;

              misc = {
                force_default_wallpaper = lib.mkDefault (-1);
                disable_hyprland_logo = lib.mkDefault false;
              };

              input = {
                kb_layout = lib.mkDefault "us";
                follow_mouse = lib.mkDefault 1;
                sensitivity = lib.mkDefault 0;
                touchpad.natural_scroll = lib.mkDefault false;
              };
            };

            curve = [
              {
                _args = [
                  "easeOutQuint"
                  {
                    type = "bezier";
                    points = [
                      [
                        0.23
                        1
                      ]
                      [
                        0.32
                        1
                      ]
                    ];
                  }
                ];
              }
              {
                _args = [
                  "easeInOutCubic"
                  {
                    type = "bezier";
                    points = [
                      [
                        0.65
                        0.05
                      ]
                      [
                        0.36
                        1
                      ]
                    ];
                  }
                ];
              }
              {
                _args = [
                  "linear"
                  {
                    type = "bezier";
                    points = [
                      [
                        0
                        0
                      ]
                      [
                        1
                        1
                      ]
                    ];
                  }
                ];
              }
              {
                _args = [
                  "almostLinear"
                  {
                    type = "bezier";
                    points = [
                      [
                        0.5
                        0.5
                      ]
                      [
                        0.75
                        1
                      ]
                    ];
                  }
                ];
              }
              {
                _args = [
                  "quick"
                  {
                    type = "bezier";
                    points = [
                      [
                        0.15
                        0
                      ]
                      [
                        0.1
                        1
                      ]
                    ];
                  }
                ];
              }
              {
                _args = [
                  "easy"
                  {
                    type = "spring";
                    mass = 1;
                    stiffness = 238.1191;
                    dampening = 24.21279333;
                  }
                ];
              }
            ];

            animation =
              map
                (
                  a:
                  {
                    enabled = true;
                  }
                  // a
                )
                [
                  {
                    leaf = "global";
                    speed = 10;
                    bezier = "default";
                  }
                  {
                    leaf = "border";
                    speed = 5.39;
                    bezier = "easeOutQuint";
                  }
                  {
                    leaf = "windows";
                    speed = 4.79;
                    spring = "easy";
                  }
                  {
                    leaf = "windowsIn";
                    speed = 4.1;
                    spring = "easy";
                    style = "popin 87%";
                  }
                  {
                    leaf = "windowsOut";
                    speed = 1.49;
                    bezier = "linear";
                    style = "popin 87%";
                  }
                  {
                    leaf = "fadeIn";
                    speed = 1.73;
                    bezier = "almostLinear";
                  }
                  {
                    leaf = "fadeOut";
                    speed = 1.46;
                    bezier = "almostLinear";
                  }
                  {
                    leaf = "fade";
                    speed = 3.03;
                    bezier = "quick";
                  }
                  {
                    leaf = "layers";
                    speed = 3.81;
                    bezier = "easeOutQuint";
                  }
                  {
                    leaf = "layersIn";
                    speed = 4;
                    bezier = "easeOutQuint";
                    style = "fade";
                  }
                  {
                    leaf = "layersOut";
                    speed = 1.5;
                    bezier = "linear";
                    style = "fade";
                  }
                  {
                    leaf = "fadeLayersIn";
                    speed = 1.79;
                    bezier = "almostLinear";
                  }
                  {
                    leaf = "fadeLayersOut";
                    speed = 1.39;
                    bezier = "almostLinear";
                  }
                  {
                    leaf = "workspaces";
                    speed = 1.94;
                    bezier = "almostLinear";
                    style = "fade";
                  }
                  {
                    leaf = "workspacesIn";
                    speed = 1.21;
                    bezier = "almostLinear";
                    style = "fade";
                  }
                  {
                    leaf = "workspacesOut";
                    speed = 1.94;
                    bezier = "almostLinear";
                    style = "fade";
                  }
                  {
                    leaf = "zoomFactor";
                    speed = 7;
                    bezier = "quick";
                  }
                ];

            gesture = {
              fingers = 3;
              direction = "horizontal";
              action = "workspace";
            };

            bind = [
              (bind "SUPER + Q" (exec cfg.terminal) { })
              (bind "SUPER + C" "hl.dsp.window.close()" { })
              (bind "SUPER + M"
                (exec "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
                { }
              )
              (bind "SUPER + E" (exec cfg.fileManager) { })
              (bind "SUPER + V" ''hl.dsp.window.float({ action = "toggle" })'' { })
              (bind "SUPER + R" (exec cfg.menu) { })
              (bind "SUPER + P" "hl.dsp.window.pseudo()" { })
              (bind "SUPER + J" ''hl.dsp.layout("togglesplit")'' { })

              (bind "SUPER + left" ''hl.dsp.focus({ direction = "left" })'' { })
              (bind "SUPER + right" ''hl.dsp.focus({ direction = "right" })'' { })
              (bind "SUPER + up" ''hl.dsp.focus({ direction = "up" })'' { })
              (bind "SUPER + down" ''hl.dsp.focus({ direction = "down" })'' { })
            ]
            ++ workspaceBinds
            ++ [
              (bind "SUPER + S" ''hl.dsp.workspace.toggle_special("magic")'' { })
              (bind "SUPER + SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'' { })
              (bind "SUPER + mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'' { })
              (bind "SUPER + mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'' { })
              (bind "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
              (bind "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

              (bind "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+") media)
              (bind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") media)
              (bind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") media)
              (bind "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") media)
              (bind "XF86MonBrightnessUp" (exec "brightnessctl -e4 -n2 set 5%+") media)
              (bind "XF86MonBrightnessDown" (exec "brightnessctl -e4 -n2 set 5%-") media)
              (bind "XF86AudioNext" (exec "playerctl next") { locked = true; })
              (bind "XF86AudioPause" (exec "playerctl play-pause") { locked = true; })
              (bind "XF86AudioPlay" (exec "playerctl play-pause") { locked = true; })
              (bind "XF86AudioPrev" (exec "playerctl previous") { locked = true; })

              # The only bindings the example does not have: it takes no screenshots.
              (bind "Print" (exec "hyprshot -m region") { })
              (bind "SHIFT + Print" (exec "hyprshot -m output") { })
            ];

            window_rule = [
              {
                name = "suppress-maximize-events";
                match.class = ".*";
                suppress_event = "maximize";
              }
              {
                name = "fix-xwayland-drags";
                match = {
                  class = "^$";
                  title = "^$";
                  xwayland = true;
                  float = true;
                  fullscreen = false;
                  pin = false;
                };
                no_focus = true;
              }
              {
                name = "move-hyprland-run";
                match.class = "hyprland-run";
                move = "20 monitor_h-120";
                float = true;
              }
            ];
          };
        };

        # GNOME reaches graphical-session.target too; this keeps waybar,
        # hypridle, hyprpaper, and the launcher out of the GNOME session.
        wayland.systemd.target = "hyprland-session.target";

        services.hyprlauncher.enable = true;
        services.hyprpolkitagent.enable = true;

        # D-Bus activated, so it only ever starts where nothing else owns
        # org.freedesktop.Notifications. One dunstrc serves every session that uses it.
        services.dunst.enable = true;

        services.hyprpaper = lib.mkIf (cfg.wallpaper != null) {
          enable = true;
          settings = {
            splash = false;
            wallpaper = [
              {
                monitor = "";
                path = toString cfg.wallpaper;
              }
            ];
          };
        };
        programs.hyprshot.enable = true;

        home.packages = with pkgs; [
          brightnessctl
          playerctl
          hyprshutdown
        ];
      }

      (lib.mkIf (cfg.wallpaper != null) {
        wayland.windowManager.hyprland.settings.config.misc.disable_hyprland_logo = true;
      })

      (lib.mkIf config.dotfiles.stylix.enable {
        stylix.targets = {
          hyprland.enable = true;
          dunst.enable = true;
        };
      })
    ]
  );
}
