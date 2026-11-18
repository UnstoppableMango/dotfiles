# Desktop

## gnome/

The GNOME option, the extension packages, and the derived `enabled-extensions` list.
The dconf preferences are taste and live in `home/gnome.nix`.

## i3/

An i3 X session beside GNOME, picked at the login screen: i3status-rust, rofi, dunst, picom, polkit-gnome, flameshot, and xss-lock with i3lock-color.

- GNOME reaches `graphical-session.target` too, so every i3 unit is rebound to `hm-graphical-session.target`, which only `~/.hm-xsession` starts.
  A unit left on the stock target would run inside GNOME as well (picom against mutter, a second locker).
- picom's package ships an XDG autostart entry that gnome-session runs, so `~/.config/autostart/picom.desktop` hides it.
  A picom inside GNOME holds Xwayland's compositor selection, and mutter then shows no X11 window.
- The session script and profile are `~/.hm-xsession` and `~/.hm-xprofile`, because the NixOS X session wrapper sources `~/.xprofile` for every X login.
- `dotfiles.i3.gnome.enable` follows `dotfiles.gnome.enable`: xsettingsd serves the `org/gnome/desktop/interface` values from `dconf.settings`, plus Super+I for Settings, Super+E for Files, and a gtk-portal `i3-portals.conf`.
  xsettingsd, because gsd-xsettings serves only mutter's Xwayland and exits under any other window manager.
- `familiarKeys`, `applets`, `autostart`, and `lock.enable` are GNOME/KDE habits, each on by default; Super+/ lists the bindings from the attrset that defines them.
- A machine varies the session through `dotfiles.i3.terminal`, `.wallpaper`, and the Home Manager options, which merge.
- The login-screen entry is system-side; see `docs/i3.md`.

## hyprland/

A Hyprland session beside GNOME and i3: waybar, hyprlauncher, dunst, hyprshot, hyprpolkitagent, hyprlock with hypridle (`lock.nix`), and hyprpaper when `dotfiles.hyprland.wallpaper` is set.

- The config is Hyprland's `example/hyprland.lua` through Home Manager's Lua generator (`configType = "lua"`, explicit because erik's stateVersion predates it as the default), with nothing carried over from `i3/`.
- waybar's settings are `waybar.json`, waybar's shipped config with the sway modules swapped for hyprland ones; hyprlock and hypridle follow upstream examples, less what needs hardware hades lacks.
- `package` and `portalPackage` are null, because the nixos repo's `programs.hyprland` owns both and the session entry; see `docs/hyprland.md`.
- `wayland.systemd.target` is `hyprland-session.target`, since GNOME also reaches `graphical-session.target`.

## stylix/, fonts/, terminals

- `stylix/` scopes Stylix to terminals (kitty, ghostty) via `dotfiles.stylix.enable`; `i3/` adds its own targets.
- `fonts/` installs Nerd Fonts (MesloLGS NF, FiraCode) and Noto Color Emoji under `dotfiles.fonts.enable`.
  The emoji font comes from the profile even where the distro ships one, because an app in a `buildFHSEnv` sandbox (Claude Desktop) sees the host's `/etc/fonts` but the sandbox's `/usr`, so only fonts Home Manager registers remain.
  The sandbox also breaks distro `/etc/fonts/conf.d` links into `/usr`, including `50-user.conf`, so `ai/claude-desktop.nix` points `FONTCONFIG_FILE` at a config that includes the user fontconfig directly.
- `kitty/` and `ghostty/` are the terminals.

## launch-services/

macOS-only; `generic@aarch64-darwin` is the only configuration that builds it.
It registers the bundles under `~/Applications/Home Manager Apps` with Launch Services (`lsregister`, behind `open -a`, the Dock, and Launchpad) and Spotlight (`mdimport`) on every activation.
Home Manager copies the bundles but tells neither, and rsync's normalized timestamps keep fsevents from triggering a reindex, so an app can be installed yet unreachable from every launcher.
Both commands only refresh an index, so the activation entry warns instead of failing.
