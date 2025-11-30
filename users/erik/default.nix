{
  imports = [
    ../../browsers/brave
    ../../editors/emacs
    ../../editors/neovim
    ../../editors/zed
    ../../shells/zsh
    ../../terminals/kitty
    ../../terminals/ghostty
    ../../toolchain/c
    ../../toolchain/dotnet
    ../../toolchain/git
    ../../toolchain/go
    ../../toolchain/k8s
    ../../toolchain/nix
    ../../toolchain/ocaml
  ];

  flake.modules.homeManager.erik = pkgs: {
    home.username = "erik";
    home.homeDirectory = "/home/erik";

    home.packages = with pkgs; [
      buf
      pay-respects
      neofetch
      github-copilot-cli
      mise
      glow
    ];

    # Let Home Manager install and manage itself
    programs.home-manager.enable = true;

    programs.grep.enable = true;
    programs.htop.enable = true;
    programs.fzf.enable = true;
    programs.jq.enable = true;
    programs.less.enable = true;

    programs.ripgrep.enable = true;
    programs.ripgrep-all.enable = true;

    programs.vim.enable = true;
    programs.micro.enable = true;
    programs.helix.enable = true;
    programs.claude-code.enable = true;

    programs.yt-dlp.enable = true;

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
    };

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.05"; # Please read the comment before changing.
  };
}
