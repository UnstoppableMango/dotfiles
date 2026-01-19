{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

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
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    devctl = {
      url = "github:unmango/devctl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        gomod2nix.follows = "gomod2nix";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    ux = {
      url = "github:unstoppablemango/ux";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    zed = {
      url = "github:zed-industries/zed?ref=v0.217.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mynix = {
      url = "github:UnstoppableMango/nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        gomod2nix.follows = "gomod2nix";
        nil.follows = "nil";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      overlay = inputs.nixpkgs.lib.composeManyExtensions (
        with inputs;
        [
          bun2nix.overlays.default
          devctl.overlays.default
          gomod2nix.overlays.default
          nil.overlays.default
          nix-direnv.overlays.default
          inputs.nix-vscode-extensions.overlays.default

          # Stupid goddamn bullshit
          # error: could not find `cargo-about` in registry `crates-io` with version `=0.8.2`
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

        ./browsers
        ./desktops
        ./editors
        ./shells
        ./terminals
        ./toolchain
        ./users
      ];

      flake.overlays.default = overlay;

      flake.modules.flake = {
        browsers = ./browsers;
        desktops = ./desktops;
        editors = ./editors;
        erik = ./users/erik;
        erasmussen = ./users/erasmussen;
        shells = ./shells;
        terminals = ./terminals;
        toolchain = ./toolchain;
      };

      nixvim = {
        packages.enable = true;
        checks.enable = true;
      };

      perSystem =
        { pkgs, ... }:
        {
          # https://github.com/nix-community/home-manager/discussions/7551
          # https://github.com/nix-community/home-manager/issues/3075
          # https://github.com/bobvanderlinden/nixos-config/blob/bdfd8d94def9dc36166ef5725589bf3d7ae2d233/flake.nix#L38-L46
          legacyPackages.homeConfigurations =
            let
              inherit (inputs.home-manager) lib;
            in
            {
              erik = lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [ self.modules.homeManager.erik ];
              };

              erasmussen = lib.homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  self.modules.homeManager.erasmussen
                  { nixpkgs.overlays = [ overlay ]; }
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
              # For the cache fallback behaviour in 2.32
              nixVersions.latest
              nixd
              nixfmt
              shellcheck
              watchexec
            ];

            DPRINT = pkgs.dprint + "/bin/dprint";
            GIT = pkgs.git + "/bin/git";
            HOMEMANAGER = pkgs.home-manager + "/bin/home-manager";
            NIXFMT = pkgs.nixfmt + "/bin/nixfmt";
            SHELLCHECK = pkgs.shellcheck + "/bin/shellcheck";
            WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
          };

          treefmt = {
            programs.nixfmt.enable = true;
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
    };
}
