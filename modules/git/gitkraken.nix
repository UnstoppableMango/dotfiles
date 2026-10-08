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
      app, so `gk auth login` is what connects it.

      Note oh-my-zsh's git plugin aliases `gk` to `gitk --all --branches &!`,
      which shadows the binary. With `dotfiles.zsh.ohMyZsh.enable` on, this
      module drops that alias
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

    # Runs after `oh-my-zsh.sh` is sourced, which defines the alias.
    programs.zsh.initContent = lib.mkIf config.dotfiles.zsh.ohMyZsh.enable ''
      unalias gk 2>/dev/null || true
    '';
  };
}
