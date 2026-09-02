{ ... }:
let
  username = "erik";
in
{
  # The floor every host stands on: the account itself, Home Manager managing
  # itself, and the shell and secret plumbing that a machine is unusable
  # without. Anything a host could reasonably do without belongs in another
  # profile.
  imports = [ ../modules ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables.DO_NOT_TRACK = "1";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you
    # do want to update the value, then make sure to first check the Home
    # Manager release notes.
    stateVersion = "25.05"; # Please read the comment before changing.
  };

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    nix.enable = true;
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
