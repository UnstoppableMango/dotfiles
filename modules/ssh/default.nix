{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ssh;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  managedKnownHosts = ".ssh/known_hosts_nix";

  # Glob, not a plain path: a non-matching glob is ignored, while a missing
  # plain Include target is an error. So the directory can be empty or absent.
  localConfigDir = ".ssh/config.d";
  localConfigGlob = "${localConfigDir}/*.conf";

  certAuthorityLines = lib.mapAttrsToList (
    pattern: key: "@cert-authority ${pattern} ${key}"
  ) cfg.certAuthorities;

  offeredIdentities =
    lib.optional (cfg.primaryIdentityFile != null) cfg.primaryIdentityFile ++ cfg.identityFiles;

  hostBlocks = lib.mapAttrs (
    name: host:
    {
      HostName = host;
    }
    // lib.optionalAttrs (cfg.hostKeyAliasDomain != null) {
      HostKeyAlias = "${name}.${cfg.hostKeyAliasDomain}";
    }
  ) cfg.hosts;
in
{
  options.dotfiles.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";

    hosts = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      description = ''
        Map of host alias to address, rendered as one `Host <alias>` block each
        so machines are reachable by bare name.

        The table itself is data the flake supplies, not something this module
        reaches for: hosts/common.nix feeds it `inputs.hosts.lib.addresses`
        (github:UnstoppableMango/hosts). The nixos repo reads that same input
        for the `internet` clan service, so the two can't drift. Consumers that
        import this module from elsewhere have to set it; empty just means no
        aliases.
      '';
    };

    hostKeyAliasDomain = lib.mkOption {
      type = with lib.types; nullOr str;
      default = "thecluster.io";
      description = ''
        Domain the machines' CA-signed host certificates are issued for. Each
        host block gets `HostKeyAlias = "<alias>.<domain>"` so OpenSSH validates
        the certificate even though we dial an IP. Set to null to skip.
      '';
    };

    certAuthorities = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {
        # Public half of the clan `openssh-ca` var, tracked in the nixos repo at
        # vars/shared/openssh-ca/id_ed25519.pub. It signs every machine's host
        # key, so trusting it here means connections never fall back to TOFU.
        "*.thecluster.io" =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIILVX94BVB3aKVgg3acqWBqMbgbbWPP+8EEZUZH+cQF";
      };
      description = ''
        Host pattern to CA public key. Written to a nix-managed known_hosts file
        as `@cert-authority` entries. NixOS machines in the clan already get this
        via /etc/ssh/ssh_known_hosts; this covers the machines that don't.
      '';
    };

    agent = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "openssh"
          "gnome"
          "1password"
        ]);
      default = if isDarwin then null else "openssh";
      defaultText = lib.literalExpression ''if isDarwin then null else "openssh"'';
      description = ''
        The one SSH agent this machine uses. A single choice rather than a
        toggle per agent, since every agent wants `SSH_AUTH_SOCK` and all but
        one would be silently ignored.

        - `openssh`: Home Manager runs OpenSSH's `ssh-agent` as a user service.
        - `gnome`: GNOME's `gcr-ssh-agent`, which the system provides (NixOS
          enables it with GNOME). Keys unlock through the login keyring.
        - `1password`: the 1Password desktop app's agent; requires
          `dotfiles.onePassword.enable`.
        - `null`: leave `SSH_AUTH_SOCK` alone. The macOS default, where launchd
          already runs an agent.
      '';
    };

    primaryIdentityFile = lib.mkOption {
      type = with lib.types; nullOr str;
      default = "~/.ssh/id_ed25519";
      description = ''
        The machine's own key, offered first. A single value rather than the
        first element of `identityFiles`, because that list collects definitions
        from other modules (modules/yubikey contributes each key's FIDO2
        credential handle) and a list option keeps only the definitions at the
        winning override priority. A host setting `identityFiles` to name its
        key would therefore discard those handles rather than precede them,
        while setting this says the one thing that differs about the host.

        Null on a machine with no key of its own.
      '';
    };

    identityFiles = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = ''
        Further private keys ssh offers, after `primaryIdentityFile`. Additive:
        every definition contributes, so a module declaring a key here does not
        displace another module's.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.agent == "1password" -> config.dotfiles.onePassword.enable;
        message = ''dotfiles.ssh.agent = "1password" requires dotfiles.onePassword.enable.'';
      }
    ];

    services.ssh-agent.enable = cfg.agent == "openssh";

    # gcr serves %t/gcr/ssh but exports nothing, so the session learns the
    # path from here, the same way Home Manager's own agent modules do it.
    sshAuthSock = lib.mkIf (cfg.agent == "gnome") {
      enable = true;
      initialization.bash = ''export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"'';
      systemd.socketProviderUnit = "gcr-ssh-agent.socket";
    };

    programs.ssh = {
      enable = true;

      # home-manager's implicit defaults are deprecated, set them explicitly.
      enableDefaultConfig = false;

      # Read before every block below, and ssh keeps the first value it obtains
      # for a parameter, so a file dropped here overrides what follows. That is
      # the seam for config this repo must not carry: a second account's key,
      # a client's jump host, anything whose existence is not public.
      includes = [ "~/${localConfigGlob}" ];

      settings = hostBlocks // {
        "*" = {
          Compression = true;
          ControlMaster = "auto";
          # %C hashes the connection tuple, so the socket path can't blow past
          # the ~104 character limit on unix domain sockets.
          #
          # That tuple is host, port, and remote user. It does not include the
          # identity, and ssh offers no token that does, so two connections to
          # the same host as the same remote user share one socket even when
          # they were told to use different keys. The second one silently
          # inherits whoever the first authenticated as; against a forge where
          # every account is git@, that means pushing as the wrong identity.
          # Anything that overrides IdentityFile must therefore override
          # ControlPath too, whether it comes from a block in ${localConfigDir}
          # or from git's core.sshCommand.
          ControlPath = "~/.ssh/master-%C";
          ControlPersist = "10m";
          AddKeysToAgent = "yes";
          # An explicit IdentityFile stops ssh from trying its built-in
          # defaults, so an empty list leaves the parameter unset rather than
          # narrowing ssh to nothing. Missing files are skipped.
          IdentityFile = lib.mkIf (offeredIdentities != [ ]) offeredIdentities;
          # The first file is the writable one, the second is nix-managed.
          UserKnownHostsFile = [
            "~/.ssh/known_hosts"
            "~/${managedKnownHosts}"
          ];
        };
      };
    };

    home.file.${managedKnownHosts} = lib.mkIf (cfg.certAuthorities != { }) {
      text = lib.concatMapStrings (line: line + "\n") certAuthorityLines;
    };
  };
}
