{
  # How checkouts are laid out is a property of the person, not the machine, so
  # this is set once here rather than per host. A host that keeps its checkouts
  # somewhere other than ~/src overrides `dotfiles.ai.checkoutRoot.path`.
  dotfiles.ai.checkoutRoot.context = ./checkout-root.md;
}
