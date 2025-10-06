# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings = {
    extra-substituters = [
      "https://unstoppablemango.cachix.org"
    ];
    extra-trusted-public-keys = [
      "unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  imports = [
    ../../editors/vscode
    ./hardware-configuration.nix
  ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hades"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";

    daemon.settings = {
      userland-proxy = false;
    };

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = (
    with pkgs;
    [
      atomix # puzzle game
      cheese # webcam tool
      epiphany # web browser
      evince # document viewer
      geary # email reader
      gedit # text editor
      gnome-characters
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
    ]
  );

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.bash;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.erik = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Erik Rasmussen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "openrazer"
    ];
    packages = with pkgs; [
      vim
      micro
      kitty
      ghostty
      k9s
      gnumake
      dprint
      buf
      (
        with dotnetCorePackages;
        combinePackages [
          sdk_9_0
          sdk_10_0-bin

          # This is OOMKilling my machine for some reason
          # sdk_10_0
        ]
      )
      go
      jetbrains.webstorm
      jetbrains.rust-rover
      jetbrains.ruby-mine
      jetbrains.rider
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      jetbrains.goland
      jetbrains.datagrip
      jetbrains.clion
      gitkraken
      bitwarden-desktop
      bitwarden-cli
      cachix
      spotify
      discord
      tutanota-desktop
      slack
      signal-desktop
      claude-code
      claude-monitor
    ];
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = ".bak";
  };

  home-manager.users.erik =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        htop
        pay-respects
        neofetch
        seabird
        gh
        github-desktop
        github-copilot-cli

        nix-zsh-completions
        zsh-nix-shell
        zsh-powerlevel10k

        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.docker
        gnomeExtensions.gsconnect
        gnomeExtensions.tweaks-in-system-menu
        gnomeExtensions.user-themes
      ];

      # Let Home Manager install and manage itself
      programs.home-manager.enable = true;

      home.shell = {
        enableZshIntegration = true;
      };

      # https://github.com/nix-community/home-manager/tree/master/modules/programs/zsh
      # shell = pkgs.zsh;
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        history = {
          expireDuplicatesFirst = true;
        };

        initContent = "source ~/.p10k.zsh";
        plugins = [
          {
            name = "powerlevel10k";
            src = pkgs.zsh-powerlevel10k;
            file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          }
        ];

        oh-my-zsh = {
          enable = true;
          plugins = [
            "sudo"
            "ssh-agent"
            "gpg-agent"

            "git"
            "nix-shell"
            "direnv"

            "nvm"
            "npm"
            "yarn"
            "deno"
            "bun"

            "golang"
            "dotnet"

            "kubectl"
            "docker"
            "helm"
          ];

          # This is printing warnings... thought it was required?
          # theme = "powerlevel10k/powerlevel10k";
        };
      };

      programs.git = {
        enable = true;
        userName = "UnstoppableMango";
        userEmail = "erik.rasmussen@unmango.dev";
        signing = {
          format = "openpgp";
          key = "264283BBFDC491BC";
          signByDefault = true;
        };
        # Still fiddling with these
        # https://github.com/git/git/blob/master/contrib/diff-highlight/README
        diff-highlight.enable = true;
        # https://github.com/so-fancy/diff-so-fancy
        # diff-so-fancy.enable = true;
        # https://github.com/Wilfred/difftastic
        # difftastic.enable = true;

        # From GitHub desktop:
        # warning: error running /nix/store/6jjz4n9w3y9c5d55n86s0sa6cfa5dkg6-github-desktop-3.4.13/opt/resources/app/git/libexec/git-core/git 'config' '--includes' '--global' '--replace-all' 'filter.lfs.process' 'git-lfs filter-process': 'error: could not lock config file /home/erik/.config/git/config: Read-only file system' 'exit status 255'. Run `git lfs install --force` to reset Git configuration.
        extraConfig = {
          push.autoSetupRemote = true;
        };
      };

      programs.neovim = {
        enable = true;
      };

      programs.emacs = {
        enable = true;
        extraPackages = epkgs: [
          epkgs.nix-mode
        ];
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

      dconf = {
        enable = true;
        settings = {
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
    };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "erik";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.firefox.enable = false; # Only blue fox
  programs.steam.enable = true;

  nixpkgs.config.allowUnfree = true;

  hardware.openrazer.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    nano
    micro
    curl
    jq
    kubectl
    kind
    yq-go
    ripgrep
    ripgrep-all

    jetbrains-mono
    openrazer-daemon
    polychromatic

    # I'll pick one eventually...
    kdePackages.breeze
    kdePackages.breeze-icons
    paper-icon-theme
    vimix-icon-theme
    papirus-icon-theme

    chrome-gnome-shell
    gnome-shell-extensions
    gnome-settings-daemon
    gnome-tweaks
    gimp3

    firefox-devedition
    google-chrome
    vlc
  ];

  environment.pathsToLink = [ "/share/zsh" ];

  fonts.packages = with pkgs; [
    meslo-lgs-nf
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    nerd-fonts.hasklug
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    nerd-fonts.noto
    nerd-fonts.open-dyslexic
    nerd-fonts.roboto-mono
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
