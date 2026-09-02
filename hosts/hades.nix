{
  pkgs,
  ...
}:
{
  imports = [
    ../home
    ../home/vscode/hades.nix
    ../profiles/base.nix
    ../profiles/dev.nix
    ../profiles/ai.nix
    ../profiles/workstation.nix
  ];

  programs.git.settings = {
    user.signingkey = "B4986C137EB15A0C91FB69FE264283BBFDC491BC";
    gpg.format = "openpgp";
  };

  dotfiles = {
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
    signal-desktop
    claude-monitor
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
}
