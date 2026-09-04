{ ... }:
{
  # The floor every host stands on: Home Manager managing itself, and the shell
  # and secret plumbing that a machine is unusable without. Anything a host
  # could reasonably do without belongs in another profile.
  #
  # Toggles only, like every profile. The account this runs as is identity, so
  # it lives in `home/account.nix`.
  imports = [ ../modules ];

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    nix.enable = true;

    # CLI only: gpg-agent already owns SSH_AUTH_SOCK (gnupg.enable above sets
    # enableSshSupport), and the two are mutually exclusive per the module's
    # own assertion. Signing stays on GPG until a host opts into
    # `dotfiles.onePassword.signingKey`.
    onePassword = {
      enable = true;
      sshAgent = false;
    };

    sops.enable = true;
    ssh.enable = true;
    zsh.enable = true;
  };

  programs = {
    # Let Home Manager install and manage itself
    home-manager.enable = true;

    grep.enable = true;
    htop.enable = true;
    fzf.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };
}
