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
  imports = [
    ./git-spice.nix
    ./gitkraken.nix
    ./opencommit.nix
    ./signing.nix
  ];

  options.dotfiles.git = {
    enable = lib.mkEnableOption "git Toolchain";

    localConfig = lib.mkOption {
      type = with lib.types; nullOr str;
      default = ".config/git/config.local";
      description = ''
        Path, relative to the home directory, of a git config file included
        from the generated one. The seam for config this repo must not carry:
        a work account's identity, a client's credential helper, anything
        whose existence is not public.

        Git ignores a missing include target, so the file is optional and
        nothing creates it. Null leaves the include out entirely.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.git;
      lfs.enable = true;

      # Home Manager renders includes after the settings, and a later
      # directive wins, so anything here overrides everything above it.
      includes = lib.optional (cfg.localConfig != null) {
        path = "${config.home.homeDirectory}/${cfg.localConfig}";
      };

      settings = {
        core.editor = "nvim";
        fetch.prune = true;
        init.defaultBranch = "main";
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
