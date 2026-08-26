{
  inputs,
  lib,
  config,
  ...
}:
{
  # sops-nix's home-manager module gates its whole config on
  # `sops.secrets != {}`, so importing it here is inert on hosts that declare
  # no secrets. imports can't live inside mkIf, hence the unconditional entry.
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  options.dotfiles.sops.enable = lib.mkEnableOption "sops-nix secret decryption";

  config = lib.mkIf config.dotfiles.sops.enable {
    # Each identity's personal age key lives at the same path regardless of
    # platform. erik's public halves are registered as the single clan user
    # `erik` in the nixos repo's sops/users/erik/key.json, one per machine
    # (hades and darter); erasmussen's key is local to this repo.
    sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    # The sops CLI itself (as opposed to sops-nix's own activation, which
    # reads sops.age.keyFile directly) falls back to an OS-specific default
    # location for the key file — on Darwin that's `~/Library/Application
    # Support/sops/age/keys.txt`, not `~/.config/...`. Exporting this points
    # an interactive `sops <file>` at the same key on every platform.
    home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
