# The subset of home/ that carries no identity (no username, email, or
# host-specific value) and is therefore the same across erik's identities,
# unlike git.nix (email) or gnome.nix (Linux/GNOME only). Exported on its own
# as `homeModules.taste` for a consumer that wants this taste without the
# rest of the identity layer.
{
  imports = [
    ./ai.nix
    ./k9s.nix
    ./kitty.nix
    ./zed.nix
  ];
}
