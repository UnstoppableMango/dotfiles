{
  programs.git = {
    settings = {
      user = {
        name = "UnstoppableMango";
        email = "erik.rasmussen@unmango.dev";
      };

      # this is what was forcing annotated tags
      tag.gpgsign = false;

      alias = {
        co = "checkout";
        ff = "merge --ff-only";
        last = "log -1 HEAD";
        unstage = "reset HEAD --";
      };
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

  dotfiles.git = {
    enable = true;
    spice.enable = true;

    # Every machine's signing key, so a commit made on one verifies on all.
    signing.allowedSigners = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMsFkHA8jLd9sHV5a/zcMsaxo/o+ZnEB95CBSRnu3YfD erik@darter"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwW6dUPKvKXXzj+gKJS7EXh6UzyLjzatrcPXa0Y2qvz erik@hades"
    ];

    # Provider, model, and key come from dotfiles.openrouter.
    openCommit = {
      enable = true;
      settings = {
        OCO_OMIT_SCOPE = false;
        OCO_GITPUSH = false;
        OCO_HOOK_AUTO_UNCOMMENT = true;
      };
    };
  };
}
