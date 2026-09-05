{ ... }:
{
  # Language toolchains and the editor that comes with them. A host that only
  # runs services takes `base` and picks toggles individually instead.
  dotfiles = {
    c.enable = true;
    containers.enable = true;
    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    neovim.enable = true;
    python.enable = true;
  };

  # tdl declares its own options upstream (`tdl.homeModules.tdl`) rather than
  # through a `dotfiles.*` toggle, so a consumer of this profile brings that
  # module along the same way they bring stylix, nixvim, and nix2git.
  programs.tdl.enable = true;
}
