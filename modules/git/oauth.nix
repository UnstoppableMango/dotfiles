{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.oauth;
in
{
  options.dotfiles.git.oauth = {
    hosts = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      example = [ "https://gitea.example.com" ];
      description = ''
        URLs that authenticate over HTTPS with git-credential-oauth. The helper
        is scoped to each URL rather than set globally, so other hosts never
        open a browser login.

        Gitea and Forgejo hosts whose name starts with `gitea.` or `forgejo.`
        need no further config: the helper uses their preregistered client.
      '';
    };

    package = lib.mkPackageOption pkgs "git-credential-oauth" { };
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.hosts != [ ]) {
    home.packages = [ cfg.package ];

    programs.git.settings.credential = lib.genAttrs cfg.hosts (_: {
      # oauth only generates tokens, so a storage helper must come first.
      helper = [
        "cache --timeout 21600"
        "${lib.getExe cfg.package}"
      ];
    });
  };
}
