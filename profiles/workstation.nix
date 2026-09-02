{ ... }:
{
  # A machine that is sat in front of all day: a full desktop session, GUI
  # editors, terminals, and a browser. `graphical` is the subset a lighter
  # host takes on its own.
  imports = [ ./graphical.nix ];

  dotfiles = {
    brave.enable = true;
    ghostty.enable = true;
    gnome.enable = true;
    helix.enable = true;
    kitty.enable = true;
    vscode.enable = true;
    zed.enable = true;
  };
}
