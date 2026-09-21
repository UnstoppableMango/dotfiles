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

  # Pop!_OS, not NixOS.
  targets.genericLinux.enable = true;

  dotfiles = {
    git.enable = true;
    git.gitkraken.enable = true;
    git.signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKd+FX/6k9udgORS0uCLkvrKNaK5BXzsYYq1WaQ7+rOO erik@darter";
    gnupg.enable = true;
    homeManager.enable = true;
    nix.enable = true;
    slip.enable = true;
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

    # OIDC context only, as a side file; the admin identity is hades'.
    kubernetes.rosequartz.enable = true;
  };

  programs = {
    home-manager.enable = true;
    tdl.enable = true;

    # Pop!_OS ships this helper built but not on PATH.
    git.settings.credential.helper = "/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret";

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };

  # Writable file first, so `kubectl config use-context` has somewhere to write.
  home.sessionVariables.KUBECONFIG = lib.concatStringsSep ":" [
    "${homeDirectory}/.kube/config"
    "${homeDirectory}/${config.dotfiles.kubernetes.rosequartz.target}"
  ];
}
