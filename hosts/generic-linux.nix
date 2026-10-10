# Literal toggles: `isLinux` comes from `pkgs`, which recurses through stylix's overlay (see AGENTS.md).
{
  imports = [ ./generic.nix ];

  dotfiles = {
    brave.enable = true;
    gnome.enable = true;
    i3.enable = true;
  };
}
