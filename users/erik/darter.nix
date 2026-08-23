{
  lib,
  config,
  ...
}:
{
  options.dotfiles.darter = lib.mkEnableOption "erik's darter laptop profile (Pop!_OS, non-NixOS)";

  config = lib.mkIf config.dotfiles.darter {
    # darter runs standalone Home Manager on Pop!_OS (not NixOS). This patches
    # XDG_DATA_DIRS and session variables so HM-installed man pages, shell
    # completions, and the locale archive resolve on a non-NixOS system.
    # Must stay off on hades, which is NixOS and integrates HM automatically.
    targets.genericLinux.enable = true;

    # darter signs with its own key (unmango.dev), distinct from hades'.
    # Matches the erik.rasmussen@unmango.dev commit email in the git module.
    programs.git.settings = {
      user.signingkey = "27DA5D049D4EEE32015BE9C29E0C29600DBC6D14";
      gpg.format = "openpgp";
    };
  };
}
