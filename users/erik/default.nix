{ pkgs, ... }:
let
  username = "erik";
in
{
  imports = [
    ../../modules
    ../shared
    ./direnv.nix
    ./git.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables.DO_NOT_TRACK = "1";

    packages = with pkgs; [
      buf
      clan-cli
      devctl
      glow
      mise
      nano
      fastfetch
      openssl
      pay-respects
      pv
      slackdump
      vhs
    ];
  };

  dotfiles = {
    ai = {
      enable = true;
      omnigent.openRouter = {
        enable = true;
        apiKeySecret = "openrouter-api-key";
      };
    };

    neovim.enable = true;
    zsh.enable = true;
    c.enable = true;

    go.enable = true;
    gnupg.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    obsidian.enable = true;
    python.enable = true;
    sops.enable = true;
    fonts.enable = true;
    ssh.enable = true;
    stylix.enable = true;
  };

  # Encrypted to both of erik's age keys (see .sops.yaml), so these decrypt on
  # darter and hades alike. Edit with `sops users/erik/secrets/<file>.yaml`.
  sops.secrets = {
    "oco-api-key" = {
      sopsFile = ./secrets/opencommit.yaml;
      key = "oco_api_key";
    };

    "openrouter-api-key" = {
      sopsFile = ./secrets/openrouter.yaml;
      key = "openrouter_api_key";
    };
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

    bat.enable = true;
    eza.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    vim.enable = true;
    micro.enable = true;

    # Disabled: yt-dlp depends on curl-cffi, whose test suite currently fails
    # to build in nixpkgs (SSL error message regex mismatch in test_verify).
    # Re-enable once upstream is fixed.
    yt-dlp.enable = false;
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
