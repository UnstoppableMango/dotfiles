# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    <nixos-hardware/asus/rog-strix/x570e>
    <nixos-hardware/common/gpu/nvidia/turing>
    <nixos-hardware/common/pc/ssd>
    <home-manager/nixos>
    ./cachix.nix
    /etc/nixos/hardware-configuration.nix
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
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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
      dotnet-sdk
      go
      jetbrains.webstorm
      jetbrains.rust-rover
      jetbrains.ruby-mine
      jetbrains.rider
      jetbrains.idea-ultimate
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
      nix = {
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };

      home.packages = with pkgs; [
        htop
        thefuck
        neofetch
        seabird
        gh
        github-desktop

        nix-zsh-completions
        zsh-nix-shell
        zsh-powerlevel10k

        gnomeExtensions.appindicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.docker
        gnomeExtensions.gsconnect
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

        # initContent = lib.mkOrder 450 ''
        #   source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        #   source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        #   source ~/.p10k.zsh
        # '';
        # initContent = lib.mkOrder 550 "source ~/.p10k.zsh";
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
            "thefuck"

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
          # theme = "powerlevel10k/powerlevel10k";
        };
      };

      programs.git = {
        enable = true;
        userName = "UnstoppableMango";
        userEmail = "erik.rasmussen@unmango.dev";
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

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
      programs.vscode = {
        enable = true;
        haskell = {
          enable = true;

          # TODO: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.haskell.hie.executablePath
          hie.enable = false;
        };

        profiles.default = {
          enableExtensionUpdateCheck = false;
          enableUpdateCheck = false;
        };

        profiles.UnstoppableMango = {
          extensions =
            with pkgs.vscode-extensions;
            [
              mkhl.direnv
              yzhang.markdown-all-in-one
              dbaeumer.vscode-eslint
              eamodio.gitlens
              ms-vscode-remote.vscode-remote-extensionpack
              github.vscode-github-actions
              editorconfig.editorconfig

              redhat.vscode-yaml
              tamasfe.even-better-toml
              jnoortheen.nix-ide
              ziglang.vscode-zig
              zxh404.vscode-proto3
              golang.go
              ms-dotnettools.csharp
              ms-dotnettools.csdevkit
              ionide.ionide-fsharp
              # ionide.ionide-fake
              rust-lang.rust-analyzer
              ocamllabs.ocaml-platform
              graphql.vscode-graphql
              graphql.vscode-graphql-syntax
              apollographql.vscode-apollo

              # TODO
              # mogeko.haskell-extension-pack
              haskell.haskell

              # TODO: Swap these around
              ms-azuretools.vscode-docker
              # docker.docker
              # ms-azuretools.vscode-containers

              ms-kubernetes-tools.vscode-kubernetes-tools
              # weaveworks.vscode-gitops-tools # TODO
            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "vscode-icontheme-nomo-dark";
                publisher = "be5invis";
                version = "1.3.7";
                sha256 = "sha256-WdRUvM5KUXU8I8/6TIkhugwgV4ECbLXnAt+LlaenvLU=";
              }
            ];

          userSettings = {
            terminal.integrated.fontFamily = "MesloLGS NF";
            workbench.iconTheme = "vs-nomo-dark";
          };
        };
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };

      dconf = {
        enable = true;
        settings."org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            appindicator.extensionUuid
            dash-to-dock.extensionUuid
            docker.extensionUuid
            gsconnect.extensionUuid
            system-monitor.extensionUuid
          ];
        };
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        settings."org/gnome/shell/extensions/dash-to-dock" = {
          dock-fixed = true;
          dock-position = "RIGHT";
          extend-height = true;
          intellihide = false;
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
    kubectl
    kind

    jetbrains-mono
    openrazer-daemon
    polychromatic
    kdePackages.breeze

    chrome-gnome-shell
    gnome-shell-extensions
    gnome-settings-daemon

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
