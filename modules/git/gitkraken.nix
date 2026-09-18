{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.gitkraken;
in
{
  options.dotfiles.git.gitkraken = {
    enable = lib.mkEnableOption ''
      the GitKraken CLI (`gk`), which drives work items and workspaces across
      several repos and forges at once: `gk work` groups branches, PRs and
      issues spanning repositories into one unit, and `gk ws` operates on a
      named set of checkouts. It shares the GitKraken account with the desktop
      app, so `gk auth login` is what connects it
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.gk-cli;
      defaultText = lib.literalExpression "pkgs.gk-cli";
      description = ''
        The gk-cli package to use. Unfree: the upstream release is a
        prebuilt binary under GitKraken's own license, so a consumer needs
        `allowUnfree` on the nixpkgs instance. Ships bash, zsh and fish
        completions under `share/`, which the profile's completion paths pick
        up without further wiring.
      '';
    };
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.enable) {
    home.packages = [ cfg.package ];
  };
}
