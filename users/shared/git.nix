{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.git.enable {
    programs.git = {
      settings = {
        user = {
          name = "UnstoppableMango";
          email = "erik.rasmussen@unmango.dev";
        };

        commit.gpgsign = true;

        # I think gpgsign=true is what was forcing annotated tags
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
  };
}
