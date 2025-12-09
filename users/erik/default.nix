{ self, ... }:
let
  username = "erik";
in
{
  imports = [
    ../../editors/neovim
    ../../shells/zsh
    ../../toolchain/c
    ../../toolchain/dotnet
    ../../toolchain/git
    ../../toolchain/go
    ../../toolchain/k8s
    ../../toolchain/nix
    ../../toolchain/ocaml
  ];

  flake.modules.homeManager.${username} =
    { pkgs, ... }:
    {
      imports = with self.modules.homeManager; [
        neovim
        zsh
        c
        dotnet
        git
        go
        k8s
        nix
        ocaml
      ];

      home.username = "${username}";
      home.homeDirectory = "/home/${username}";

      home.packages = with pkgs; [
        buf
        crc
        glow
        mise
        neofetch
        pay-respects
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

      programs.yt-dlp.enable = true;

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
