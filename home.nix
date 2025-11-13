{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      pay-respects
      neofetch
      seabird
      github-desktop
      github-copilot-cli
      mise
      nixd

      nix-zsh-completions
      zsh-nix-shell
      zsh-powerlevel10k

      # For gsconnect
      nautilus-python

      (
        with pkgs.dotnetCorePackages;
        combinePackages [
          sdk_9_0
          sdk_10_0
          dotnet_10.aspnetcore
        ]
      )
    ]
    ++ (with pkgs.gnomeExtensions; [
      appindicator
      dash-to-dock
      docker
      tweaks-in-system-menu
      user-themes
      gsconnect
    ]);

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  home.shell = {
    enableZshIntegration = true;
  };

  programs.grep.enable = true;
  programs.htop.enable = true;
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.less.enable = true;
  programs.ripgrep.enable = true;
  programs.ripgrep-all.enable = true;

  programs.kitty.enable = true;
  programs.ghostty.enable = true;

  programs.brave.enable = true;

  # https://github.com/nix-community/home-manager/tree/master/modules/programs/zsh
  # shell = pkgs.zsh;
  programs.zsh = import ./shells/zsh/home-manager.nix { inherit pkgs; };

  programs.git = {
    enable = true;
    lfs.enable = true;

    # From GitHub desktop:
    # warning: error running /nix/store/6jjz4n9w3y9c5d55n86s0sa6cfa5dkg6-github-desktop-3.4.13/opt/resources/app/git/libexec/git-core/git 'config' '--includes' '--global' '--replace-all' 'filter.lfs.process' 'git-lfs filter-process': 'error: could not lock config file /home/erik/.config/git/config: Read-only file system' 'exit status 255'. Run `git lfs install --force` to reset Git configuration.
    settings = {
      user = {
        name = "UnstoppableMango";
        email = "erik.rasmussen@unmango.dev";
      };

      push.autoSetupRemote = true;
    };
    signing = {
      format = "openpgp";
      key = "264283BBFDC491BC";
      signByDefault = true;
    };
  };

  # Still fiddling with these
  # https://github.com/git/git/blob/master/contrib/diff-highlight/README
  programs.diff-highlight = {
    enable = true;
    enableGitIntegration = true;
  };
  # https://github.com/so-fancy/diff-so-fancy
  # programs.diff-so-fancy.enable = true;
  # https://github.com/Wilfred/difftastic
  # programs.difftastic.enable = true;

  programs.micro.enable = true;
  programs.helix.enable = true;
  programs.zed-editor.enable = true;

  programs.vim.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
    ];
  };

  programs.claude-code = {
    enable = true;
  };

  programs.k9s.enable = true;
  programs.gh.enable = true;

  programs.opam = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gcc.enable = true;

  programs.go = {
    enable = true;
    telemetry.mode = "off";
  };

  programs.vscode = import ./editors/vscode/home-manager.nix { inherit pkgs; };

  programs.lutris.enable = true;
  programs.yt-dlp.enable = true;

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  dconf = {
    enable = true;
    settings = {
      "org/freedesktop/ibus/panel/emoji" = {
        # Disable ctrl+shift+u unicode shortcut, conflicts with JetBrains keybinds
        # https://superuser.com/questions/358749/how-to-disable-ctrlshiftu/1392682#1392682
        unicode-hotkey = "@as []";
      };

      # dconf dump / > tmp.dconf
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          appindicator.extensionUuid
          dash-to-dock.extensionUuid
          docker.extensionUuid
          gsconnect.extensionUuid
          system-monitor.extensionUuid
          tweaks-in-system-menu.extensionUuid
          user-themes.extensionUuid
        ];
      };
      "org/gnome/desktop/interface" = {
        accent-color = "pink";
        clock-format = "12h";
        clock-show-seconds = false;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        cursor-theme = "breeze_cursors";
        enable-hot-corners = false;
        icon-theme = "Papirus";
        monospace-font-name = "FiraCode Nerd Font Mono 11";
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        autohide = false;
        custom-background-color = false;
        custom-theme-shrink = true;
        dash-max-icon-size = 48;
        dock-fixed = true;
        dock-position = "RIGHT";
        extend-height = true;
        intellihide = false;
        running-indicator-dominant-color = false;
        running-indicator-style = "DOTS";
        show-show-apps-button = true; # This is not a typo
        show-trash = false;
        unity-backlit-items = false;
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
  home.stateVersion = "25.05"; # Please read the comment before changing.
}
