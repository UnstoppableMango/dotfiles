{
  inputs,
  pkgs,
  config,
  ...
}:
let
  username = "erasmussen";
in
{
  imports = with inputs; [
    direnv-instant.homeModules.direnv-instant

    ../../shells/zsh
    ../../editors
    ../../terminals
    ../../toolchain

    ./gnupg.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      bat
      buf
      cursor-cli
      fnm
      github-copilot-cli
      gitkraken
      glow
      pay-respects
      pwgen
      spotify
      vhs
    ];
  };

  dotfiles = {
    neovim.enable = true;
    vscode.enable = true;
    zsh.enable = true;
    ghostty.enable = true;
    kitty.enable = true;
    zed.enable = true;
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

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    direnv-instant = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableKittyIntegration = config.dotfiles.kitty.enable;
    };

    claude-code.enable = true;
  };

  programs.git = {
    settings = {
      user = {
        signingkey = "E4BD93BB75AEC2AC";
      };
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
