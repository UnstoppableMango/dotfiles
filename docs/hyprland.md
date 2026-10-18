# Hyprland session

`dotfiles.hyprland.enable` writes `~/.config/hypr/hyprland.lua` and the session's user units, but it sets `wayland.windowManager.hyprland.package = null`, so it installs no Hyprland.
The system layer supplies the compositor, the login-screen entry, xdg-desktop-portal-hyprland, and the PAM service hyprlock authenticates against.

## NixOS (hades)

In the nixos repo's machine configuration:

```nix
programs.hyprland.enable = true;
security.pam.services.hyprlock = { };
```

`programs.hyprland` adds a "Hyprland" entry to GDM's gear menu.
`services.displayManager.defaultSession = "gnome"` keeps autologin on GNOME, the same as for i3.
The Hyprland package ships `hyprland-portals.conf` (`default=hyprland;gtk`), so GNOME's gtk portal covers what xdg-desktop-portal-hyprland does not implement, with nothing to configure here.
Leave `programs.hyprland.withUWSM` off: Home Manager's `hyprland-session.target` does the systemd integration, and the Hyprland wiki notes the two conflict.

## What the session is

The config is Hyprland's own `example/hyprland.lua` from the release nixpkgs carries, written through Home Manager's Lua generator (`configType = "lua"`), so the bindings are the example's: Super+Q for the terminal, Super+C to close, Super+M to exit, Super+E for files, Super+R for the launcher, Super+S for the scratchpad.
Print and Shift+Print (hyprshot, region and output) are the only bindings the example does not have.
Stylix supplies the colors; everything else is an option default a host overrides with a plain assignment.
waybar, hyprlock, and hypridle start from their own upstream examples too (see the comments in `modules/hyprland/`).

The monitor rule is the example's catch-all (`output = ""`, preferred mode, auto position and scale).
A host with a real layout sets `wayland.windowManager.hyprland.settings.monitor` to a list of `{ output, mode, position, scale }` entries.

## Switching

All three sessions stay installed; the login screen picks one.
`wayland.systemd.target` is `hyprland-session.target`, which only Hyprland starts, so waybar, hypridle, hyprpaper, hyprlauncher, and hyprpolkitagent stay out of GNOME, which reaches `graphical-session.target` too.
Check from a GNOME session with `systemctl --user is-active waybar hypridle`, which should print `inactive` twice.
dunst is D-Bus activated and GNOME owns the notification name, so it never starts there; its one `dunstrc` is shared with the i3 session.

To check the generated config without logging in: `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`.
