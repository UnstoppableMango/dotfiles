{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd.url = "github:nix-community/nixd";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ux = {
      url = "github:unstoppablemango/ux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # https://wiki.nixos.org/wiki/Zed
    # https://github.com/zed-industries/zed/blob/main/flake.nix
    zed = {
      url = "github:zed-industries/zed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.home-manager.flakeModules.home-manager
        inputs.nixvim.flakeModules.default
      ];

      flake = {
        homeModules = {
          dconf = ./desktops/gnome/dconf/home.nix;
          erik = ./users/erik/home.nix;
          gnome = ./desktops/gnome/home.nix;
          neovim = ./editors/neovim/home.nix;
          nixvim = ./editors/nixvim/home.nix;
          vscode = ./editors/vscode/home.nix;
          zed = ./editors/zed/home.nix;
          zsh = ./shells/zsh/home.nix;
        };

        nixvimModules = {
          default = ./editors/nixvim/module.nix;
        };
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem =
        {
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          nixvimConfigurations = {
            default = inputs.nixvim.lib.evalNixvim {
              inherit system;
              modules = [
                self.nixvimModules.default
              ];
            };
          };

          # https://github.com/nix-community/home-manager/discussions/7551
          # https://github.com/nix-community/home-manager/issues/3075
          # https://github.com/bobvanderlinden/nixos-config/blob/bdfd8d94def9dc36166ef5725589bf3d7ae2d233/flake.nix#L38-L46
          legacyPackages = {
            homeConfigurations."erik" = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = [
                inputs.nixvim.homeModules.nixvim
                self.homeModules.erik
                # https://github.com/nix-community/home-manager/issues/2954
                { nixpkgs.config.allowUnfree = true; }
              ];
            };
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              direnv
              dprint
              git
              gnumake
              home-manager
              ldns
              nil
              nixd
              nixfmt-rfc-style
              shellcheck
              watchexec
            ];

            DPRINT = pkgs.dprint + "/bin/dprint";
            GIT = pkgs.git + "/bin/git";
            HOMEMANAGER = pkgs.home-manager + "/bin/home-manager";
            NIXFMT = pkgs.nixfmt-rfc-style + "/bin/nixfmt";
            SHELLCHECK = pkgs.shellcheck + "/bin/shellcheck";
            WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
          };

          treefmt = {
            programs.nixfmt.enable = true;
            programs.nixfmt.package = pkgs.nixfmt-rfc-style;

            programs.dprint = {
              enable = false; # Causing issues with flake checks
              settings.plugins = (
                pkgs.dprint-plugins.getPluginList (
                  plugins: with plugins; [
                    dprint-plugin-json
                    dprint-plugin-markdown
                    g-plane-markup_fmt
                    g-plane-pretty_yaml
                  ]
                )
              );
            };
          };
        };

      nixvim = {
        packages.enable = true;
        checks.enable = true;
      };
    };
}
