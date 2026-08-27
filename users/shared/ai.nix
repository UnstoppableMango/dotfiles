{
  # How checkouts are laid out is a property of the person, not the machine, so
  # both identities get the same document. An identity that keeps its checkouts
  # somewhere other than ~/src overrides `dotfiles.ai.checkoutRoot.path`.
  dotfiles.ai.checkoutRoot.context = ./checkout-root.md;
}
