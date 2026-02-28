{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        package = pkgs.gitFull;
        lfs.enable = true;

        settings = {
          core = {
            editor = "nvim";
          };

          user = {
            name = "UnstoppableMango";
            email = "erik.rasmussen@unmango.dev";
          };

          alias = {
            co = "checkout";
            ff = "merge --ff-only";
            last = "log -1 HEAD";
            unstage = "reset HEAD --";
          };

          push.autoSetupRemote = true;
        };

        ignores = [
          "**/node_modules/"
          ".DS_Store"
          ".direnv/"
          ".envrc"
          ".idea/**/discord.xml"
          ".worktree/"
        ];
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

      programs.gh.enable = true;
    };
}
