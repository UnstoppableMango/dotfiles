{
  lib,
  config,
  ...
}:
let
  inherit (config.home) homeDirectory;
in
{
  # darter runs standalone Home Manager on Pop!_OS (not NixOS). This patches
  # XDG_DATA_DIRS and session variables so HM-installed man pages, shell
  # completions, and the locale archive resolve on a non-NixOS system.
  targets.genericLinux.enable = true;

  programs.git.settings = {
    user.signingkey = "27DA5D049D4EEE32015BE9C29E0C29600DBC6D14";
    gpg.format = "openpgp";
  };

  dotfiles = {
    ai.omnigent.enable = false;

    # rosequartz's admin cert is clan-generated and darter isn't a clan
    # machine, so darter gets the OIDC context only, as a side file.
    kubernetes.rosequartz.enable = true;
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
