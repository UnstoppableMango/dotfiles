{
  lib,
  config,
  ...
}:
let
  inherit (config.home) homeDirectory;
in
{
  imports = [ ../home ];

  # darter runs standalone Home Manager on Pop!_OS (not NixOS). This patches
  # XDG_DATA_DIRS and session variables so HM-installed man pages, shell
  # completions, and the locale archive resolve on a non-NixOS system.
  targets.genericLinux.enable = true;

  dotfiles = {
    git.enable = true;
    git.gitkraken.enable = true;
    git.signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsFkHA8jLd9sHV5a/zcMsaxo/o+ZnEB95CBSRnu3YfD erik@darter";
    gnupg.enable = true;
    homeManager.enable = true;
    nix.enable = true;
    sops.enable = true;
    ssh.enable = true;
    yubikey.enable = true;
    yubikey.gui = true;
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;

    c.enable = true;
    containers.enable = true;
    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    neovim.enable = true;
    python.enable = true;

    ai = {
      enable = true;
      claudeDesktop.enable = true;
      omnigent.enable = false;
    };

    # A display, but no desktop session.
    fonts.enable = true;
    obsidian.enable = true;
    signal.enable = true;
    stylix.enable = true;
    zed.enable = true;

    # rosequartz's admin cert is clan-generated and darter isn't a clan
    # machine, so darter gets the OIDC context only, as a side file.
    kubernetes.rosequartz.enable = true;
  };

  programs = {
    home-manager.enable = true;
    tdl.enable = true;

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };

  # The first file is the writable hand-managed one, the second is
  # nix-managed - same shape as modules/ssh's UserKnownHostsFile. Keeping
  # the writable file first means `kubectl config use-context` still has
  # somewhere to write.
  home.sessionVariables.KUBECONFIG = lib.concatStringsSep ":" [
    "${homeDirectory}/.kube/config"
    "${homeDirectory}/${config.dotfiles.kubernetes.rosequartz.target}"
  ];
}
