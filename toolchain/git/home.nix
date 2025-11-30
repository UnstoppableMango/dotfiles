{
  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = "UnstoppableMango";
        email = "erik.rasmussen@unmango.dev";
      };

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

  programs.gh.enable = true;
}
