{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles;
  inherit (pkgs.stdenv.hostPlatform) isLinux;

  on =
    names:
    lib.genAttrs names (_: {
      enable = lib.mkDefault true;
    });
in
{
  # Each role sets `mkDefault` on the toggles it covers, so a host turns any one
  # of them back off with a plain `false`.
  options.dotfiles = {
    base.enable = lib.mkEnableOption "the floor: git, gnupg, nix, sops, ssh, zsh, and the small CLI tools";
    dev.enable = lib.mkEnableOption "language toolchains, neovim, and the agent CLIs";
    desktop.enable = lib.mkEnableOption "fonts, theming, terminals, GUI editors, a browser, and the desktop session";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.base.enable {
      dotfiles = on [
        "git"
        "gnupg"
        "nix"
        "onePassword"
        "sops"
        "ssh"
        "zsh"
      ];

      programs = on [
        "home-manager"
        "grep"
        "htop"
        "fzf"
        "jq"
        "less"
        "ripgrep"
        "vim"
      ];
    })

    (lib.mkIf cfg.dev.enable {
      dotfiles = lib.mkMerge [
        (on [
          "ai"
          "c"
          "containers"
          "go"
          "javascript"
          "kubernetes"
          "neovim"
          "python"
        ])
        { ai.claudeDesktop.enable = lib.mkDefault true; }
      ];

      programs.tdl.enable = lib.mkDefault true;
    })

    (lib.mkIf cfg.desktop.enable {
      dotfiles = lib.mkMerge [
        (on [
          "fonts"
          "ghostty"
          "helix"
          "kitty"
          "obsidian"
          "stylix"
          "vscode"
          "zed"
        ])
        # A Linux desktop session; darwin has its own.
        {
          brave.enable = lib.mkDefault isLinux;
          gnome.enable = lib.mkDefault isLinux;
        }
      ];
    })
  ];
}
