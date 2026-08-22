{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/triplet";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      # Explicitly leaving nixpkgs unpinned because hm likes to provide its own
    };

    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/26.05.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # Explicitly leaving nixpkgs unpinned because nixvim likes to provide its own
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    nix-direnv = {
      url = "github:nix-community/nix-direnv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    nix-init = {
      url = "github:nix-community/nix-init";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nurl.inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    devctl = {
      url = "github:unmango/devctl";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.gomod2nix.follows = "gomod2nix";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    ux = {
      url = "github:unstoppablemango/ux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.gomod2nix.follows = "gomod2nix";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    zed = {
      url = "github:zed-industries/zed?ref=v0.217.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangopkgs = {
      url = "github:unmango/pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
      inputs.gomod2nix.follows = "gomod2nix";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    mynix = {
      url = "github:UnstoppableMango/nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.gomod2nix.follows = "gomod2nix";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.systems.follows = "systems";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
      # stylix's flake.nix does not declare a treefmt-nix input - do not add
      # inputs.treefmt-nix.follows, it will fail eval.
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
      # nix-darwin only declares a nixpkgs input - no other follows are valid.
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      overlay = inputs.nixpkgs.lib.composeManyExtensions (
        with inputs;
        [
          devctl.overlays.default
          mangopkgs.overlays.default
          nil.overlays.default
          nix-direnv.overlays.default
          nix-vscode-extensions.overlays.default

          (final: prev: {
            inherit (clan-core.packages.${prev.stdenv.hostPlatform.system}) clan-cli;
          })

          # cargo-about pin conflict is resolved upstream (zed's own nix/build.nix
          # now vendors cargo-about via fetchFromGitHub), but a new mismatch surfaced:
          # nixpkgs' livekit-libwebrtc is out of sync with zed 0.217.3's expected
          # webrtc API (`no type named 'AudioDeviceSink' in namespace 'webrtc'`).
          # zed.overlays.default
        ]
      );
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        flake-parts.flakeModules.modules
        home-manager.flakeModules.home-manager
        nixvim.flakeModules.default
        treefmt-nix.flakeModule
      ];

      flake = {
        overlays.dotfiles = overlay;
        overlays.default = overlay;

        homeModules = {
          erik = ./users/erik;
          erasmussen = ./users/erasmussen;
        };

        darwinModules.erasmussen = ./darwin/erasmussen;

        darwinConfigurations."Eriks-MacBook-Pro" = inputs.nix-darwin.lib.darwinSystem {
          modules = [
            { nixpkgs.overlays = [ overlay ]; }
            self.darwinModules.erasmussen
            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.sharedModules = [ inputs.stylix.homeModules.stylix ];
              home-manager.users.erasmussen = self.homeModules.erasmussen;
            }
          ];
        };

        homeConfigurations =
          let
            inherit (inputs.home-manager.lib) homeManagerConfiguration;
            inherit (inputs.nixpkgs) legacyPackages;

            modules = [
              { nixpkgs.overlays = [ overlay ]; }
              { nixpkgs.config.allowUnfree = true; }
              inputs.stylix.homeModules.stylix
              self.homeModules.erik
            ];
          in
          {
            "erik@darter" = homeManagerConfiguration {
              pkgs = legacyPackages.x86_64-linux;
              extraSpecialArgs = { inherit inputs; };
              inherit modules;
            };

            "erik@hades" = homeManagerConfiguration {
              pkgs = legacyPackages.x86_64-linux;
              extraSpecialArgs = { inherit inputs; };
              modules = modules ++ [ { dotfiles.hades = true; } ];
            };

            "erasmussen@Eriks-MacBook-Pro.local" = homeManagerConfiguration {
              pkgs = legacyPackages.aarch64-darwin;
              extraSpecialArgs = { inherit inputs; };
              modules = [
                { nixpkgs.overlays = [ overlay ]; }
                { nixpkgs.config.allowUnfree = true; }
                inputs.stylix.homeModules.stylix
                self.homeModules.erasmussen
              ];
            };
          };
      };

      nixvim = {
        packages.enable = true;
        checks.enable = true;
      };

      perSystem =
        { inputs', pkgs, ... }:
        {
          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              age
              bashInteractive
              direnv
              git
              gnumake
              home-manager
              inputs'.clan-core.packages.clan-cli
              ldns
              nil
              nix
              nixd
              nixfmt
              shellcheck
              ssh-to-age
              sops
              watchexec
            ];

            GIT = pkgs.git + "/bin/git";
            HOMEMANAGER = pkgs.home-manager + "/bin/home-manager";
            NIXFMT = pkgs.nixfmt + "/bin/nixfmt";
            SHELLCHECK = pkgs.shellcheck + "/bin/shellcheck";
            WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
          };

          treefmt = {
            programs.nixfmt.enable = true;
            programs.prettier.enable = true;
          };
        };
    };
}
