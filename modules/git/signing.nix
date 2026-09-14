{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.signing;
  isSsh = cfg.format == "ssh";

  defaultEmail = config.programs.git.settings.user.email;

  signer = lib.types.submodule {
    options = {
      key = lib.mkOption {
        type = lib.types.str;
        description = "SSH public key.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = defaultEmail;
        defaultText = lib.literalExpression "config.programs.git.settings.user.email";
        description = "Identity the key's signatures verify as.";
      };
    };
  };

  # `git log --show-signature` needs each key mapped to an identity.
  allowedSigners = pkgs.writeText "allowed_signers" (
    lib.concatMapStrings (line: line + "\n") (
      lib.unique (
        map (s: "${s.email} ${s.key}") (
          [
            {
              inherit (cfg) key;
              email = defaultEmail;
            }
          ]
          ++ cfg.allowedSigners
        )
      )
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
      type = with lib.types; listOf (coercedTo str (key: { inherit key; }) signer);
      default = [ ];
      example = lib.literalExpression ''
        [
          "ssh-ed25519 AAAA... erik@darter"
          { email = "erik@example.com"; key = "ssh-ed25519 AAAA..."; }
        ]
      '';
      description = ''
        SSH public keys trusted as this user's signatures, in addition to
        `key`: typically every machine's signing key, so commits made
        elsewhere verify here too. A bare key verifies as the git
        `user.email`; `{ email, key }` names a different identity, for a key
        that signs under another email.
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
