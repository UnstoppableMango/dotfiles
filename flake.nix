{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    systems.url = "github:UnstoppableMango/nix-systems";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
      inputs.sops-nix.follows = "sops-nix";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hosts = {
      url = "github:UnstoppableMango/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
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

    nix2git = {
      url = "github:unmango/nix2git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.home-manager.follows = "home-manager";
      inputs.systems.follows = "systems";
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
    };

    tdl = {
      url = "github:UnstoppableMango/tdl";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.gomod2nix.follows = "gomod2nix";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.home-manager.follows = "home-manager";
    };

    slip = {
      url = "github:unmango/slip";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.mangopkgs.follows = "mangopkgs";
    };

    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      overlay = import ./overlay.nix { inherit inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        systems.flakeModule

        home-manager.flakeModules.home-manager
        treefmt-nix.flakeModule
      ];

      flake = {
        overlays.dotfiles = import ./overlay.nix { inherit inputs; };
        overlays.default = self.overlays.dotfiles;

        homeModules = {
          dotfiles.imports = with inputs; [
            nix2git.homeModules.nix2git
            tdl.homeModules.tdl
            ./modules
          ];
        };

        nixvimModules.default = ./modules/neovim/nixvim-config.nix;

        homeConfigurations =
          let
            homeFor =
              system: host:
              inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${system};
                extraSpecialArgs = { inherit self; };
                modules =
                  (with inputs; [
                    stylix.homeModules.stylix
                    nixvim.homeModules.nixvim
                    sops-nix.homeManagerModules.sops
                    direnv-instant.homeModules.direnv-instant
                    self.homeModules.dotfiles
                  ])
                  ++ [
                    (import ./hosts/common.nix { inherit inputs; })
                    host
                  ];
              };
          in
          {
            "erik@darter" = homeFor "x86_64-linux" ./hosts/darter.nix;
            "erik@hades" = homeFor "x86_64-linux" ./hosts/hades.nix;
            "erik@server" = homeFor "x86_64-linux" ./hosts/server.nix;
            "tz@hades" = homeFor "x86_64-linux" ./hosts/tz-hades.nix;
            "generic@x86_64-linux" = homeFor "x86_64-linux" ./hosts/generic.nix;
            "generic@aarch64-darwin" = homeFor "aarch64-darwin" ./hosts/generic.nix;
            "generic@container" = homeFor "x86_64-linux" ./hosts/container.nix;
          };
      };

      perSystem =
        {
          inputs',
          lib,
          system,
          pkgs,
          ...
        }:
        {
          packages = {
            nixvim =
              (inputs.nixvim.lib.evalNixvim {
                inherit system;
                modules = [
                  { nixpkgs.overlays = [ overlay ]; }
                  self.nixvimModules.default
                ];
              }).config.build.package;
          }
          // lib.optionalAttrs (system == "x86_64-linux") (
            let
              container = import ./container.nix {
                inherit pkgs lib;
                inherit (inputs'.nix2container.packages) nix2container;
                inherit (self.homeConfigurations."generic@container".config.home) username homeDirectory path;
                putterManifest = self.homeConfigurations."generic@container".config.home.internal.filePutterConfig;
              };
            in
            {
              container = container.image;
              # The profile the image names but does not carry. CI builds it
              # so the cache holds it before any pod asks for it.
              container-env = container.env;
            }
          );

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
          };

          treefmt = {
            programs.nixfmt.enable = true;
            programs.prettier.enable = true;

            # sops rewrites these files in its own YAML layout on every edit,
            # so prettier re-indenting them turns each edit into two diffs.
            settings.global.excludes = [ "home/secrets/*" ];
          };
        };
    };
}
