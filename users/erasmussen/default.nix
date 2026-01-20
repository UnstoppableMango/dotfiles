{ inputs, config, ... }:
let
  username = "erasmussen";
in
{
  flake.modules.homeManager.${username} =
    { pkgs, ... }:
    {
      imports = with config.flake.modules.homeManager; [
        inputs.nixvim.homeModules.nixvim
        neovim
        toolchain
        zsh
      ];

      home = {
        inherit username;

        homeDirectory = "/Users/${username}";

        packages = with pkgs; [
          buf
          cursor-cli
          github-copilot-cli
          glow
          pay-respects
          vhs
        ];
      };

      openshift.enable = true;

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

        claude-code.enable = true;
      };

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "26.05"; # Please read the comment before changing.
    };
}
