# Literal toggles: `isLinux` comes from `pkgs`, which recurses through stylix's overlay (see hosts/AGENTS.md).
{
  imports = [ ./generic.nix ];

  dotfiles = {
    bizhawk.enable = true;
    brave.enable = true;
    gnome.enable = true;
    hyprland.enable = true;
    i3.enable = true;
  };
}
