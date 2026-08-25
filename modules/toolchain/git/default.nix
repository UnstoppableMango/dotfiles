{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./repos.nix ];

  options.dotfiles.git.enable = lib.mkEnableOption "git Toolchain";

  config = lib.mkIf config.dotfiles.git.enable {
    programs.git = {
      enable = true;
      package = pkgs.git;
      lfs.enable = true;

      settings = {
        core.editor = "nvim";
        push.autoSetupRemote = true;
      };
    };

    # Still fiddling with these
    # https://github.com/git/git/blob/master/contrib/diff-highlight/README
    programs.diff-highlight = {
      enable = true;
      enableGitIntegration = true;
    };
    # https://github.com/so-fancy/diff-so-fancy
    # programs.diff-so-fancy.enable = true;
    # https://github.com/Wilfred/difftastic
    # programs.difftastic.enable = true;

    programs.gh = {
      enable = true;
      extensions = [ pkgs.gh-stack ];
    };
  };
}
