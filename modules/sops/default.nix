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
    # erik's personal age key. Its public halves are registered as the single
    # clan user `erik` in the nixos repo's sops/users/erik/key.json, which
    # carries one key per machine (hades and darter), so every machine
    # decrypts the same secrets from the same path.
    sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
