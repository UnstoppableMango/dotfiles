{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.yubikey;

  withSshKey = lib.filterAttrs (_: key: key.sshKey != null) cfg.keys;

  offered = lib.filterAttrs (name: _: lib.elem name cfg.availableKeys) withSshKey;

  undeclared = lib.subtractLists (lib.attrNames cfg.keys) cfg.availableKeys;

  # The name `ssh-keygen -K` gives a downloaded handle: the FIDO2 application
  # with the `ssh:` prefix stripped, so the bare default yields an unsuffixed
  # file. Only a default, since `handle` names the path outright.
  downloadedAs =
    application:
    let
      suffix = lib.removePrefix "ssh:" application;
    in
    "~/.ssh/id_ed25519_sk_rk" + lib.optionalString (suffix != "") "_${suffix}";

  offeredHandles = lib.mapAttrsToList (_: key: key.handle) offered;

  handleCounts = lib.foldl' (acc: h: acc // { ${h} = (acc.${h} or 0) + 1; }) { } offeredHandles;

  collidingHandles = lib.attrNames (lib.filterAttrs (_: n: n > 1) handleCounts);
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
        lib.types.submodule (
          # `config` here is the key's own options, not the home configuration.
          { name, config, ... }:
          {
            options = {
              sshKey = lib.mkOption {
                type = with lib.types; nullOr str;
                default = null;
                example = "sk-ssh-ed25519@openssh.com AAAA... erik@yubikey-nano";
                description = ''
                  Public half of the key's resident FIDO2 SSH credential.
                  Recorded for authorized_keys and forges; ssh itself reads
                  the credential handle that `ssh-keygen -K` writes, at the
                  path `application` decides.
                '';
              };

              application = lib.mkOption {
                type = lib.types.strMatching "ssh:.*";
                default = "ssh:${name}";
                defaultText = lib.literalExpression ''"ssh:''${name}"'';
                example = "ssh:";
                description = ''
                  FIDO2 application the credential was created under, fixed at
                  creation by `-O application=`. ssh-keygen requires the
                  `ssh:` prefix and uses a bare `ssh:` by default.

                  Whatever follows the prefix is what `ssh-keygen -K` appends
                  to a handle it downloads, which is where `handle` gets its
                  default. The application also scopes the credential on the
                  authenticator, so two credentials on one key need different
                  applications, while the same application across different
                  keys is the ordinary case.
                '';
              };

              handle = lib.mkOption {
                type = lib.types.str;
                default = downloadedAs config.application;
                defaultText = lib.literalMD ''
                  `~/.ssh/id_ed25519_sk_rk`, with `_` and `application`'s
                  suffix appended when it has one.
                '';
                example = "~/.ssh/yubikey";
                description = ''
                  Path ssh offers for this key's credential handle, and so the
                  path the downloaded file has to end up at.

                  Defaults to the name `ssh-keygen -K` writes, which follows
                  `application`. Setting it decouples the two, which is safe
                  because ssh reads a handle by its content and never checks
                  the path against the credential. The cost is that `-K` then
                  writes a name this does not match, leaving a rename to do by
                  hand, and ssh passes over a handle that is not there without
                  saying so.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = ''
        The user's YubiKeys by name. The name labels the key for
        `availableKeys` and defaults its FIDO2 `application`, which in turn
        defaults the `handle` ssh offers.
      '';
    };

    availableKeys = lib.mkOption {
      type = with lib.types; listOf str;
      default = lib.attrNames cfg.keys;
      defaultText = lib.literalExpression "lib.attrNames config.dotfiles.yubikey.keys";
      example = lib.literalExpression ''[ "darter" "keychain" ]'';
      description = ''
        Names of the keys this machine is ever plugged into, whose credential
        handles ssh offers. Which keys a machine has is true of that machine
        alone, so a host sets this; `keys` stays the whole set the user owns.

        Defaults to every declared key, which is right for a consumer that
        declares only the keys it holds. Narrowing matters because each
        offered identity costs one authentication attempt, and a server's
        `MaxAuthTries` is 6 by default.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = undeclared == [ ];
        message = ''
          dotfiles.yubikey.availableKeys names keys absent from
          dotfiles.yubikey.keys: ${lib.concatStringsSep ", " undeclared}.
        '';
      }
      {
        assertion = collidingHandles == [ ];
        message = ''
          dotfiles.yubikey: more than one available key offers the handle
          ${lib.concatStringsSep ", " collidingHandles}. Two keys cannot share
          one file, so give each its own `handle`, or distinct FIDO2
          applications to default them apart.
        '';
      }
    ];

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

    # Only this machine's keys: each offered handle costs an authentication attempt.
    # Missing handles are skipped, and `identityFiles` is additive.
    dotfiles.ssh.identityFiles = offeredHandles;

    # Share the card through pcscd so gpg-agent does not lock out ykman.
    programs.gpg.scdaemonSettings = lib.mkIf config.programs.gpg.enable {
      disable-ccid = true;
      pcsc-shared = true;
    };
  };
}
