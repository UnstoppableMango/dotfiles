{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  # Identity-free build coverage for `homeModules.dotfiles`; not a real machine.
  home = {
    username = "generic";
    homeDirectory = if isDarwin then "/Users/generic" else "/home/generic";
    stateVersion = "25.05";
  };

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    homeManager.enable = true;
    nix.enable = true;
    onePassword.enable = true;
    slip.enable = true;
    sops.enable = true;
    ssh.enable = true;
    # Builds the 1Password socket branch on both platforms.
    ssh.agent = "1password";
    yubikey.enable = true;
    yubikey.gui = true;
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;

    c.enable = true;
    containers.enable = true;
    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    neovim.enable = true;
    python.enable = true;

    ai = {
      enable = true;
      claudeDesktop.enable = true;
    };

    fonts.enable = true;
    ghostty.enable = true;
    helix.enable = true;
    kitty.enable = true;
    obsidian.enable = true;
    signal.enable = true;
    stylix.enable = true;
    vscode.enable = true;
    vscodium.enable = true;
    zed.enable = true;

    brave.enable = isLinux;
    gnome.enable = isLinux;
  };

  # Both editors ship `lib/vscode/LICENSES.chromium.html`; VSCodium does not
  # read its copy from the profile.
  programs.vscodium.package = lib.lowPrio pkgs.vscodium;

  programs = {
    home-manager.enable = true;
    tdl.enable = true;

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };
}
