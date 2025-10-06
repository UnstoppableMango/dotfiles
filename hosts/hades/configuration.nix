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

        profiles.Hades = {
          extensions =
            with pkgs.vscode-extensions;
            [
              mkhl.direnv
              yzhang.markdown-all-in-one
              dbaeumer.vscode-eslint
              eamodio.gitlens
              ms-vscode-remote.remote-containers
              ms-vscode-remote.remote-ssh
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
              ms-dotnettools.vscodeintellicode-csharp
              ms-dotnettools.vscode-dotnet-runtime
              ionide.ionide-fsharp
              rust-lang.rust-analyzer
              ocamllabs.ocaml-platform
              graphql.vscode-graphql
              graphql.vscode-graphql-syntax
              apollographql.vscode-apollo

              # TODO
              # mogeko.haskell-extension-pack
              haskell.haskell

              ms-kubernetes-tools.vscode-kubernetes-tools
            ]
            ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "vscode-icontheme-nomo-dark";
                publisher = "be5invis";
                version = "1.3.7";
                sha256 = "sha256-WdRUvM5KUXU8I8/6TIkhugwgV4ECbLXnAt+LlaenvLU=";
              }
              {
                name = "ionide-fake";
                publisher = "ionide";
                version = "1.2.3";
                sha256 = "sha256-SeiW8zHWwaOc+OlRI2jxdIZFhe6eSvb1kDGs2li3T0Y=";
              }
              {
                name = "docker";
                publisher = "docker";
                version = "0.17.0";
                sha256 = "sha256-c1M5pC8JGm+IKQIviE163kYQOX8Nx0Gty7rV7OQCy88=";
              }
              {
                name = "vscode-gitops-tools";
                publisher = "weaveworks";
                version = "0.27.0";
                sha256 = "sha256-7MCKDnHCot/CL/SqZ2WuTxbqFdF75EC5WC+OxW0dcaE=";
              }
              {
                name = "project-manager";
                publisher = "alefragnani";
                version = "12.8.0";
                sha256 = "sha256-sNiDyWdQ40Xeu7zp1ioRCi3majrPshlVbUSV2klr4r4=";
              }
              {
                name = "vscode-buf";
                publisher = "bufbuild";
                version = "0.8.1";
                sha256 = "sha256-pJG1vrx5BmI+60rh+OkeVASDLQPQGNaeAYs/07Va438=";
              }
              {
                name = "dprint";
                publisher = "dprint";
                version = "0.16.7";
                sha256 = "sha256-9o3mEmQ/8XjWnqpTjsVG4iYv1pe71ZRMO11PNmm6z4k=";
              }
              {
                name = "shellcheck";
                publisher = "timonwong";
                version = "0.38.3";
                sha256 = "sha256-qDispRN7jRIIsP+5lamyR+sNoOwTwl+55QftzO7WBm4=";
              }
              {
                name = "vscode-containers";
                publisher = "ms-azuretools";
                version = "2.2.0";
                sha256 = "sha256-UxWsu7AU28plnT0QMdpPJrcYZIV09FeC+rmYKf39a6M=";
              }
              {
                name = "helm-intellisense";
                publisher = "tim-koehler";
                version = "0.15.0";
                sha256 = "sha256-Tl0X2jtgTsjf2tvyAJLGxEGrmLXACYWWErcDJuQYg+o=";
              }
              {
                name = "shell-format";
                publisher = "foxundermoon";
                version = "7.2.8";
                sha256 = "sha256-Z3vmRzqPCxkQbn39I54bh/ND+0HcE9iFUhKQ29GRd7o=";
              }
              {
                name = "resharper-code";
                publisher = "JetBrains";
                version = "0.0.11";
                sha256 = "sha256-UxvwGkefK/b6/sK8WcCis2MWRNkPH/hHAy2BY7GfW70=";
              }
            ];

          userSettings = {
            terminal.integrated.fontFamily = "MesloLGS NF";
            workbench.iconTheme = "vs-nomo-dark";
            redhat.telemetry.enabled = false;
            # https://github.com/alefragnani/vscode-project-manager/blob/master/README.md#available-settings
            projectManager = {
              git = {
                baseFolders = [
                  "~/src/github.com/UnstoppableMango"
                  "~/src/github.com/unmango"
                  "~/src/github.com/pulumiverse"
                ];
              };
              tags = [
                "Personal"
                "Work"
                "FOSS"
              ];
            };
          };
        };
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
