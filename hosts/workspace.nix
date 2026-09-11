{ lib, pkgs, ... }:
{
  # The container workspace `packages.workspace-image` ships: the same base,
  # dev, and ai toolchains a development machine gets, with nothing that needs
  # hardware, a display, or a login session.
  #
  # Like `server.nix`, the account comes from `home/account.nix` rather than
  # from all of `home/`, because the personal layer carries sops secrets
  # encrypted to keys an image published anywhere has no business holding.
  imports = [
    ../home/account.nix
    ../profiles/base.nix
    ../profiles/dev.nix
    ../profiles/ai.nix
  ];

  home.username = "erik";

  dotfiles.ai = {
    # An Electron desktop app, on a machine with no display.
    claudeDesktop.enable = lib.mkForce false;

    # omnigent installs itself through `uv tool install` during Home Manager
    # activation, which the image entrypoint runs on every container start.
    # That reaches the network for a Python interpreter each time and fails
    # without one. `profiles/ai.nix` also points it at a sops secret that only
    # `home/` declares, and the module asserts the name resolves.
    omnigent.enable = lib.mkForce false;
    omnigent.openRouter.enable = lib.mkForce false;
  };

  # The image entrypoint runs `claude remote-control` as PID 1 itself. The
  # module's only output is a systemd user unit, and a container has no user
  # manager to load it, so the options are read by `packages/workspace-image.nix`
  # rather than acted on here.
  dotfiles.ai.remoteControl = {
    enable = false;
    # `worktree` wants rootDir to be a git repository, and the checkout root
    # the default rootDir points at is a directory of them.
    spawn = "same-dir";
    permissionMode = "acceptEdits";
  };

  # gnupg module hardcodes pinentry-gnome3, which needs a GNOME/D-Bus session
  services.gpg-agent.pinentry = {
    package = lib.mkForce pkgs.pinentry-curses;
    program = lib.mkForce "pinentry-curses";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
