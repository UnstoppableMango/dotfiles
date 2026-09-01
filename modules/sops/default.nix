{
  lib,
  config,
  ...
}:
{
  options.dotfiles.sops.enable = lib.mkEnableOption "sops-nix secret decryption";

  config = lib.mkIf config.dotfiles.sops.enable {
    # Each identity's age key lives at the same path on every platform.
    sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    # The sops CLI defaults elsewhere on Darwin; point it at the same key file.
    home.sessionVariables.SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
