{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.hades = lib.mkEnableOption "erik's hades desktop profile";

  config = lib.mkIf config.dotfiles.hades {
    programs.git.settings = {
      user.signingkey = "B4986C137EB15A0C91FB69FE264283BBFDC491BC";
      gpg.format = "openpgp";
    };

    dotfiles = {
      gnome.enable = true;
      brave.enable = true;
      vscode.enable = true;
      zed.enable = true;
      helix.enable = true;
      ghostty.enable = true;
      kitty.enable = true;
      containers.enable = true;
      ocaml.enable = true;
      dotnet.enable = true;
    };

    programs.lutris.enable = true;

    home.packages = with pkgs; [
      devenv
      jetbrains-toolbox
      gitkraken
      bitwarden-cli
      cachix
      github-desktop
      seabird
      spotify
      discord
      tutanota-desktop
      slack
      webex
      signal-desktop
      claude-monitor
      omnissa-horizon-client
      xmage

      (wineWow64Packages.full.override {
        wineRelease = "staging";
        mingwSupport = true;
      })
      winetricks

      kdePackages.breeze
      kdePackages.breeze-icons
      paper-icon-theme
      vimix-icon-theme
      papirus-icon-theme
      gimp3
      firefox-devedition
      google-chrome
      vlc
    ];
  };
}
