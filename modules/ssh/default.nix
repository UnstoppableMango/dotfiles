{ lib, config, ... }:
{
  options.dotfiles.ssh.enable = lib.mkEnableOption "SSH client configuration";

  config = lib.mkIf config.dotfiles.ssh.enable {
    # Agent/forwarding is provided by gnupg's gpg-agent
    # (services.gpg-agent.enableSshSupport = true; see modules/gnupg).
    # This module only manages client behavior - no secret material,
    # no sops-nix/agenix.
    programs.ssh = {
      enable = true;

      # home-manager's implicit defaults are deprecated, set them explicitly.
      enableDefaultConfig = false;

      settings."*" = {
        Compression = true;
        HashKnownHosts = true;
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "10m";
        AddKeysToAgent = "yes";
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };

      # matchBlocks."host-alias" = { hostname = "..."; user = "..."; };
      # left empty intentionally - no host-specific data known here.
    };
  };
}
