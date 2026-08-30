{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.spice;
in
{
  options.dotfiles.git.spice = {
    enable = lib.mkEnableOption ''
      git-spice (`gs`), a stacked-branch workflow on top of plain git: each
      branch in a stack tracks its parent, `gs` restacks the whole stack on
      rebase, and `gs stack submit` opens or updates one change request per
      branch with the right base. Unlike gh-stack it is forge-agnostic,
      speaking GitHub, GitLab, Bitbucket, Gitea and Forgejo, which is what
      makes it usable against the gitlab.com checkouts as well.

      Note the binary is named `gs`, which collides with ghostscript's. Only
      one of the two can win a PATH lookup, so keep them out of the same
      profile
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.git-spice;
      defaultText = lib.literalExpression "pkgs.git-spice";
      description = ''
        The git-spice package to use. Ships bash, zsh and fish completions
        under `share/`, which the profile's completion paths pick up without
        further wiring.
      '';
    };

    settings = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = { };
      example = {
        submit.navigationComment = "multiple";
        forge.gitlab.removeSourceBranch = true;
      };
      description = ''
        Entries for the `spice` section of the git config. git-spice keeps all
        of its configuration in git config rather than a file of its own, so
        these land in `~/.config/git/config` alongside everything else and
        nest one level deep: `submit.draft` here is `spice.submit.draft`
        there. See https://abhinav.github.io/git-spice/cli/config/.

        Repository state (which branch stacks onto which) is not
        configuration; it lives in a `refs/spice/` ref per repo and is written
        by `gs repo init`.
      '';
    };
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.enable) {
    home.packages = [ cfg.package ];

    # Guarded: an empty attrset still renders a bare `[spice]` header into the
    # generated gitconfig.
    programs.git.settings = lib.mkIf (cfg.settings != { }) { spice = cfg.settings; };
  };
}
