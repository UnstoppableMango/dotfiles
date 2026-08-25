{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.openCommit;
in
{
  options.dotfiles.git.openCommit.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      opencommit (`oco`) wired in as a git template hook: `git init`/`git
      clone` symlinks every new repo's `prepare-commit-msg` hook straight to
      the `oco` binary, the same mechanism `oco hook set` uses per-repo, so
      commit messages get auto-drafted from the staged diff in Conventional
      Commit form. Needs an OCO_API_KEY (or a local OCO_AI_PROVIDER such as
      ollama) exported in the shell; unset means the hook silently no-ops on
      the config step. Disabled by default. Existing repos need `git init`
      re-run once (safe, idempotent) to pick up the hook.
    '';
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.enable) {
    home.packages = [ pkgs.opencommit ];

    # oco detects "I'm running as a git hook" by checking that
    # process.argv[1] is exactly $GIT_DIR/hooks/prepare-commit-msg, which is
    # how `oco hook set` wires a repo up (a symlink from the hook path to its
    # own cli script). nixpkgs' `bin/oco` is a bash wrapper that execs node
    # with the store path to cli.cjs hardcoded as the script argument, which
    # overwrites argv[1] and breaks that detection. Symlinking straight to
    # cli.cjs preserves the hook path in argv[1] instead.
    xdg.configFile."git/template/hooks/prepare-commit-msg".source =
      "${pkgs.opencommit}/lib/node_modules/opencommit/out/cli.cjs";

    programs.git.settings.init.templateDir = "${config.xdg.configHome}/git/template";
  };
}
