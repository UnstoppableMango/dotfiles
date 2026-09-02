{ ... }:
{
  # The minimum a host needs once it has a display: fonts to render with, a
  # theme to render in, and the notes app that follows the person rather than
  # the machine. A headless host does not import this file.
  dotfiles = {
    fonts.enable = true;
    obsidian.enable = true;
    stylix.enable = true;
  };
}
