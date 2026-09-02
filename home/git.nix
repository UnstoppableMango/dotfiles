{
  programs.git = {
    settings = {
      user = {
        name = "UnstoppableMango";
        email = "erik.rasmussen@unmango.dev";
      };

      commit.gpgsign = true;

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
    openCommit = {
      enable = true;
      apiKeySecret = "oco-api-key";
      settings = {
        OCO_AI_PROVIDER = "anthropic";
        OCO_MODEL = "claude-sonnet-4-6";
        OCO_OMIT_SCOPE = false;
        OCO_GITPUSH = false;
        OCO_HOOK_AUTO_UNCOMMENT = true;
      };
    };
  };
}
