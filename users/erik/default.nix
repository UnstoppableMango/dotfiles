{ self, ... }:
let
  username = "erik";
in
{
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

      home = {
        inherit username;

        homeDirectory = "/home/${username}";

        packages = with pkgs; [
          buf
          crc
          glow
          mise
          neofetch
          pay-respects
        ];
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
    };
}
