{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.sops;
in
{
  options.dotfiles.sops = {
    enable = lib.mkEnableOption "sops-nix secret decryption";

    keyFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/sops/age/keys.txt";
      defaultText = lib.literalExpression ''"''${config.xdg.configHome}/sops/age/keys.txt"'';
      description = ''
        The machine's software age identities, read unattended by sops-nix at
        activation. YubiKey (age-plugin-yubikey) identities do not belong here,
        since they need the key plugged in and a PIN.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.age.keyFile = cfg.keyFile;

    # The sops CLI defaults elsewhere on Darwin; point it at the same key file.
    home.sessionVariables.SOPS_AGE_KEY_FILE = cfg.keyFile;
  };
}
