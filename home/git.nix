{
  programs.git = {
    settings = {
      user = {
        name = "UnstoppableMango";
        email = "erik.rasmussen@unmango.dev";
      };

      # Signing tags forces them to be annotated.
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

    signing.allowedSigners = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKd+FX/6k9udgORS0uCLkvrKNaK5BXzsYYq1WaQ7+rOO erik@darter"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwW6dUPKvKXXzj+gKJS7EXh6UzyLjzatrcPXa0Y2qvz erik@hades"
    ];

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
