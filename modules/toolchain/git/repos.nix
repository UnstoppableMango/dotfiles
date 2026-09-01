{ inputs, ... }:
{
  # https://gitlab.com/unmango/nix/2git
  #
  # Declares `nix2git.repositories`, an attrset of paths under the home
  # directory that get a `git init` on activation when nothing is there yet.
  # It never clones, rewrites, or deletes; a repository already in place is
  # left alone, and dropping an entry warns rather than removing anything.
  imports = [ inputs.nix2git.homeModules.nix2git ];
}
