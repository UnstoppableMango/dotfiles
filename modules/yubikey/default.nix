{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.yubikey;
in
{
  options.dotfiles.yubikey = {
    enable = lib.mkEnableOption ''
      YubiKey tooling for the OpenPGP, FIDO2, OATH, and PIV applets.

      Home Manager cannot provide the system half: `pcscd` and the YubiKey
      udev rules. On NixOS set `services.pcscd.enable = true;` and
      `services.udev.packages = [ pkgs.yubikey-personalization ];`; elsewhere
      install the distribution's `pcscd` and udev rule packages'';

    gui = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Yubico Authenticator (Linux only).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        yubikey-manager
        yubico-piv-tool
        libfido2
        yubikey-personalization
      ]
      ++ lib.optional (cfg.gui && stdenv.hostPlatform.isLinux) yubioath-flutter;

    # Go through pcscd and share the card, so a running gpg-agent does not
    # lock ykman and Yubico Authenticator out of the key.
    programs.gpg.scdaemonSettings = lib.mkIf config.programs.gpg.enable {
      disable-ccid = true;
      pcsc-shared = true;
    };
  };
}
