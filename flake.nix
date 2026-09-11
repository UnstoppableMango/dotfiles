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
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      clan = import ./overlays/clan.nix { inherit (inputs) clan-core; };
      vscodePkg = import ./overlays/vscode.nix;

      overlay = inputs.nixpkgs.lib.composeManyExtensions (
        with inputs;
        [
          devctl.overlays.default
          mangopkgs.overlays.default
          nil.overlays.default
          nix-direnv.overlays.default
          nix-vscode-extensions.overlays.default
          # Composes gomod2nix's overlay in, since tdl is built with its
          # buildGoApplication, so buildGoApplication and mkGoEnv land in pkgs
          # alongside `tdl` and `vscode-tdl`.
          tdl.overlays.default
          clan.overlays.default
          vscodePkg.overlays.default

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
        systems.flakeModule

        home-manager.flakeModules.home-manager
        treefmt-nix.flakeModule
      ];

      flake = {
        overlays.dotfiles = overlay;
        overlays.default = overlay;

        homeModules = {
          # ./modules alone declares no programs.tdl.* option (tdl has no
          # dotfiles.* toggle of its own, see AGENTS.md), so the tdl flake's
          # homeModule is folded in here too, letting a consumer of
          # `homeModules.dotfiles` set `programs.tdl.enable` without also
          # importing `tdl.homeModules.tdl` themselves.
          dotfiles.imports = with inputs; [
            ./modules
            tdl.homeModules.tdl
          ];
        };

        nixvimModules.default = ./modules/neovim/nixvim-config.nix;

        homeConfigurations =
          let
            home =
              system: host:
              inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = inputs.nixpkgs.legacyPackages.${system};
                extraSpecialArgs = { inherit inputs self; };
                modules = [
                  ./hosts/common.nix
                  host
                ];
              };
          in
          {
            "erik@darter" = home "x86_64-linux" ./hosts/darter.nix;
            "erik@hades" = home "x86_64-linux" ./hosts/hades.nix;

            # No machine is named `server`. This exists so `hosts/server.nix`
            # is built by `nix flake check` like the other two, rather than
            # being an export that only breaks in whatever flake consumes it.
            "erik@server" = home "x86_64-linux" ./hosts/server.nix;

            # No machine is named `workspace` either. This is the home
            # configuration `packages.workspace-image` bakes into an OCI image,
            # kept here for the same reason as `erik@server`.
            "erik@workspace" = homeManagerConfiguration {
              pkgs = legacyPackages.x86_64-linux;
              extraSpecialArgs = { inherit inputs self; };
              modules = common ++ [ ./hosts/workspace.nix ];
            };

            "generic@x86_64-linux" = home "x86_64-linux" ./hosts/generic.nix;
            "generic@aarch64-darwin" = home "aarch64-darwin" ./hosts/generic.nix;
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
          # `homeConfigurations."erik@workspace"` is x86_64-linux, and
          # dockerTools cannot cross-build the image from anywhere else.
          // lib.optionalAttrs (system == "x86_64-linux") {
            workspace-image = pkgs.callPackage ./packages/workspace-image.nix {
              homeConfiguration = self.homeConfigurations."erik@workspace";
            };
          };

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
          };
        };
    };
}
