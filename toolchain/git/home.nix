{
  programs.git = {
    enable = true;
    lfs.enable = true;

    # From GitHub desktop:
    # warning: error running /nix/store/6jjz4n9w3y9c5d55n86s0sa6cfa5dkg6-github-desktop-3.4.13/opt/resources/app/git/libexec/git-core/git 'config' '--includes' '--global' '--replace-all' 'filter.lfs.process' 'git-lfs filter-process': 'error: could not lock config file /home/erik/.config/git/config: Read-only file system' 'exit status 255'. Run `git lfs install --force` to reset Git configuration.
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
