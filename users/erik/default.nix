{ pkgs, ... }:
let
  username = "erik";
in
{
  imports = [
    ../../browsers
    ../../desktops
    ../../editors
    ../../shells
    ../../terminals
    ../../toolchain

    ./ai.nix
    ./gnupg.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      buf
      glow
      mise
      nano
      fastfetch
      openssl
      pay-respects
      vhs
    ];
  };

  dotfiles = {
    brave.enable = true;
    emacs.enable = true;
    gnome.enable = true;
    helix.enable = true;
    neovim.enable = true;
    zsh.enable = true;
    ghostty.enable = true;
    kitty.enable = true;
    c.enable = true;
    containers.enable = true;
    dotnet.enable = true;
    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    openshift.enable = true;
    ocaml.enable = true;
    python.enable = true;
  };

  programs = {
    # Let Home Manager install and manage itself
    home-manager.enable = true;

    grep.enable = true;
    htop.enable = true;
    fzf.enable = true;
    jq.enable = true;
    less.enable = true;

    ripgrep.enable = true;
    ripgrep-all.enable = true;

    vim.enable = true;
    micro.enable = true;

    yt-dlp.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;

      # Tempted... we'll see if it keeps annoying me
      silent = false;

      # Pulumi repos use mise
      mise.enable = true;
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
