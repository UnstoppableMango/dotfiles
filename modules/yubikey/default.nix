{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.yubikey;

  withSshKey = lib.filterAttrs (_: key: key.sshKey != null) cfg.keys;
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

    keys = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.sshKey = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "sk-ssh-ed25519@openssh.com AAAA... erik@yubikey-nano";
            description = ''
              Public half of the key's resident FIDO2 SSH credential, created
              with `-O application=ssh:<name>`. Recorded for authorized_keys
              and forges; ssh itself reads the credential handle that
              `ssh-keygen -K` writes to `~/.ssh/id_ed25519_sk_rk_<name>`.
            '';
          };
        }
      );
      default = { };
      description = ''
        The user's YubiKeys by name. The name is the suffix of the FIDO2
        application (`ssh:<name>`), which fixes the handle's file name.
      '';
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
      ++ lib.optional (cfg.gui && stdenv.hostPlatform.isLinux) yubioath-flutter
      # Decrypts with a key's PIV slot, for when the machine's age key is gone.
      ++ lib.optional config.dotfiles.sops.enable age-plugin-yubikey;

    # Missing handles are skipped, so a machine that has not run
    # `ssh-keygen -K` yet still connects with its other keys. These go in
    # `identityFiles`, which is additive, rather than ahead of the machine's own
    # key in `dotfiles.ssh.primaryIdentityFile`.
    dotfiles.ssh.identityFiles = lib.mapAttrsToList (
      name: _: "~/.ssh/id_ed25519_sk_rk_${name}"
    ) withSshKey;

    # Go through pcscd and share the card, so a running gpg-agent does not
    # lock ykman, age-plugin-yubikey, and Yubico Authenticator out of the key.
    programs.gpg.scdaemonSettings = lib.mkIf config.programs.gpg.enable {
      disable-ccid = true;
      pcsc-shared = true;
    };
  };
}
