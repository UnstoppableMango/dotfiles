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
}
