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
    ]
    ++ (with pkgs.gnomeExtensions; [
      appindicator
      dash-to-dock
      docker
      tweaks-in-system-menu
      user-themes
      gsconnect
    ])
    ++ (
      with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_9_0
        sdk_10_0
      ]
    );

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
          github.copilot
          anthropic.claude-code
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
          myriad-dreamin.tinymist
          bradlc.vscode-tailwindcss

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
          {
            name = "bun-vscode";
            publisher = "oven";
            version = "0.0.31";
            sha256 = "sha256-KlsXU1UpkxaX1rI16CD0KMhe7aarv8A94ZZ0TxlI5Ns=";
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
