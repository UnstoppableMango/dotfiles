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

  # ssh-keygen(1) ALLOWED SIGNERS; a malformed one silently never matches.
  timestamp = lib.types.strMatching "[0-9]{8}([0-9]{4}([0-9]{2})?)?Z?";

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

      validAfter = lib.mkOption {
        type = lib.types.nullOr timestamp;
        default = null;
        example = "20260920";
        description = ''
          Earliest signature this key verifies, as `valid-after`. Null places
          no lower bound.
        '';
      };

      validBefore = lib.mkOption {
        type = lib.types.nullOr timestamp;
        default = null;
        example = "20260920Z";
        description = ''
          Latest signature this key verifies, as `valid-before`. Null places no
          upper bound.

          Git checks a signature against the time it was created rather than
          the time it is verified, so bounding a key on the day it is retired
          leaves every commit it already signed verifying. Without a bound,
          dropping the key from this list unverifies its whole history.

          A bare date is midnight, so a key retired partway through a day
          needs the day after it or an explicit `HHMM`.
        '';
      };
    };
  };

  # `principals [options] keytype base64 comment`; `key` carries the last three.
  signerLine =
    s:
    let
      options = lib.concatStringsSep "," (
        lib.optional (s.validAfter != null) ''valid-after="${s.validAfter}"''
        ++ lib.optional (s.validBefore != null) ''valid-before="${s.validBefore}"''
      );
    in
    lib.concatStringsSep " " ([ s.email ] ++ lib.optional (options != "") options ++ [ s.key ]);

  allowedSigners = pkgs.writeText "allowed_signers" (
    lib.concatMapStrings (line: line + "\n") (
      lib.unique (
        map signerLine (
          [
            {
              inherit (cfg) key;
              email = defaultEmail;
              validAfter = null;
              validBefore = null;
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
          { key = "ssh-ed25519 AAAA..."; validBefore = "20260920"; }
        ]
      '';
      description = ''
        SSH public keys trusted as this user's signatures, in addition to
        `key`: typically every machine's signing key, so commits made
        elsewhere verify here too. A bare key verifies as the git
        `user.email`; `{ email, key }` names a different identity, for a key
        that signs under another email.

        `validAfter` and `validBefore` bound the window a key's signatures
        verify in, which is what makes a retired key keep verifying the
        commits it already signed. See those options.
      '';
    };
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.key != null) {
    programs.git = {
      signing = {
        inherit (cfg) format;
        key = if isSsh then "key::${cfg.key}" else cfg.key;
      };

      # Not signByDefault, which turns every lightweight tag into an annotated one.
      settings = {
        commit.gpgSign = true;
        gpg.ssh.allowedSignersFile = lib.mkIf isSsh (toString allowedSigners);
      };
    };
  };
}
