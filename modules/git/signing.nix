{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.signing;
  isSsh = cfg.format == "ssh";

  # `git log --show-signature` needs each key mapped to an identity. Derived
  # from the git email rather than restated, so the two can't drift.
  allowedSigners = pkgs.writeText "allowed_signers" (
    lib.concatMapStrings (key: "${config.programs.git.settings.user.email} ${key}\n") (
      lib.unique ([ cfg.key ] ++ cfg.allowedSigners)
    )
  );
in
{
  options.dotfiles.git.signing = {
    key = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "ssh-ed25519 AAAA... erik@hades";
      description = ''
        The key this machine signs commits with: an SSH public key for the
        `ssh` format, a fingerprint for `openpgp`. For SSH, the private half
        has to be in the agent (see `dotfiles.ssh.agent`). Null leaves commits
        unsigned.
      '';
    };

    format = lib.mkOption {
      type = lib.types.enum [
        "ssh"
        "openpgp"
      ];
      default = "ssh";
      description = "Signature format.";
    };

    allowedSigners = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        SSH public keys trusted as this user's signatures, in addition to
        `key`: typically every machine's signing key, so commits made
        elsewhere verify here too.
      '';
    };
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.key != null) {
    programs.git = {
      signing = {
        inherit (cfg) format;
        key = if isSsh then "key::${cfg.key}" else cfg.key;
      };

      # Commits only. signByDefault would sign tags too, which makes every
      # lightweight tag an annotated one.
      settings = {
        commit.gpgSign = true;
        gpg.ssh.allowedSignersFile = lib.mkIf isSsh (toString allowedSigners);
      };
    };
  };
}
