{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git;
in
{
  options.dotfiles.git.repos = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Path to the repo, relative to the home directory.";
            };

            remote = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = "URL for the `origin` remote. Left unset if null.";
            };

            branch = lib.mkOption {
              type = lib.types.str;
              default = "main";
              description = "Initial branch name, passed to `git init -b`.";
            };
          };
        }
      )
    );
    default = { };
    description = ''
      Git repositories to initialize under the home directory on activation.
      Each attribute name is both the default `path` and the repo's
      identifier. An empty attrset (the default) disables the feature
      entirely, no activation script is registered.
    '';
  };

  config = lib.mkIf (cfg.repos != { }) {
    home.activation.gitRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          _: repo:
          let
            dir = "${config.home.homeDirectory}/${repo.path}";
          in
          ''
            if [ ! -d ${lib.escapeShellArg dir}/.git ]; then
              $DRY_RUN_CMD ${pkgs.git}/bin/git -C ${lib.escapeShellArg dir} init -b ${lib.escapeShellArg repo.branch}
            fi
          ''
          + lib.optionalString (repo.remote != null) ''
            if ! ${pkgs.git}/bin/git -C ${lib.escapeShellArg dir} remote get-url origin >/dev/null 2>&1; then
              $DRY_RUN_CMD ${pkgs.git}/bin/git -C ${lib.escapeShellArg dir} remote add origin ${lib.escapeShellArg repo.remote}
            fi
          ''
        ) cfg.repos
      )
    );
  };
}
