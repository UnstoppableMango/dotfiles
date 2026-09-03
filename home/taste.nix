# The subset of erik's preferences that carries no identity (no username,
# email, or host-specific value) and is therefore the same across erik's
# identities, unlike git.nix (email) or gnome.nix (Linux/GNOME only).
#
# Flips the four dotfiles.profile.* toggles declared in
# modules/profile/default.nix; the curated values themselves are option
# defaults in modules/kitty, modules/kubernetes/k9s, modules/zed, and
# modules/ai/checkout-root.nix, applied only when their toggle is on.
#
# Exported on its own as `homeModules.taste` for a consumer that wants this
# taste without the rest of the identity layer. A consumer that wants only
# one piece (say, just the kitty colors) can instead set a single
# `dotfiles.profile.<tool>.enable` directly against
# `homeModules.dotfiles`, without importing this file at all.
{
  dotfiles.profile = {
    ai.enable = true;
    k9s.enable = true;
    kitty.enable = true;
    zed.enable = true;
  };
}
