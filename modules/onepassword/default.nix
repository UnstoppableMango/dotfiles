{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.onePassword;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  # The desktop app owns both the agent socket and the signing helper; neither
  # ships in the CLI package, and neither is installable from nixpkgs on macOS.
  # The app is a sandboxed bundle there, so the socket sits under its group
  # container and the helper inside the bundle.
  agentSocket =
    if isDarwin then
      "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${config.home.homeDirectory}/.1password/agent.sock";

  sshSignProgram =
    if isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      "${pkgs._1password-gui}/share/1password/op-ssh-sign";

  # `git log --show-signature` and forge-side verification both need the key
  # mapped to an identity. Derived from the git identity rather than restated,
  # so the two can't drift.
  allowedSigners = pkgs.writeText "allowed_signers" ''
    ${config.programs.git.settings.user.email} ${cfg.signingKey}
  '';
in
{
  options.dotfiles.onePassword = {
    enable = lib.mkEnableOption "1Password CLI and SSH agent integration";

    sshAgent = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Point OpenSSH at 1Password's agent socket instead of whatever agent is
        already in the environment.

        This is exclusive with gpg-agent's SSH support: both want to own
        `SSH_AUTH_SOCK`, and the loser is silently ignored. An assertion below
        catches the overlap rather than letting it surface as a key that just
        never offers itself.
      '';
    };

    signingKey = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        SSH public key (`ssh-ed25519 AAAA...`) 1Password holds the private half
        of. When set, git signs commits with it through `op-ssh-sign` instead of
        GPG. The literal is identity data, so it comes from `users/`.

        Null leaves git's signing configuration alone, which is what a machine
        that still signs with GPG wants.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.sshAgent && config.services.gpg-agent.enableSshSupport);
        message = ''
          dotfiles.onePassword.sshAgent and services.gpg-agent.enableSshSupport
          both claim SSH_AUTH_SOCK. Pick one: disable dotfiles.gnupg on this
          machine, or set dotfiles.onePassword.sshAgent = false.
        '';
      }
    ];

    home.packages = [ pkgs._1password-cli ];

    programs.ssh = lib.mkIf cfg.sshAgent {
      enable = true;
      # Quoted because the macOS group container path contains spaces.
      settings."*".IdentityAgent = ''"${agentSocket}"'';
    };

    programs.git.settings = lib.mkIf (cfg.signingKey != null) {
      user.signingkey = cfg.signingKey;
      gpg = {
        format = "ssh";
        ssh = {
          program = sshSignProgram;
          allowedSignersFile = toString allowedSigners;
        };
      };
    };
  };
}
