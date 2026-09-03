{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    systems.url = "github:nix-systems/triplet";

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
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    let
      clan = import ./overlays/clan.nix { inherit (inputs) clan-core; };
      tdlPkg = import ./overlays/tdl.nix { inherit (inputs) tdl; };

      overlay = inputs.nixpkgs.lib.composeManyExtensions (
        with inputs;
        [
          devctl.overlays.default
          mangopkgs.overlays.default
          nil.overlays.default
          nix-direnv.overlays.default
          nix-vscode-extensions.overlays.default
          clan.overlays.default
          tdlPkg.overlays.default

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
        home-manager.flakeModules.home-manager
        treefmt-nix.flakeModule
      ];

      flake = {
        overlays.dotfiles = overlay;
        overlays.default = overlay;

        homeModules = {
          dotfiles = ./modules;

          # The profiles, as named bundles of enable toggles carrying no
          # identity, published so a third party building a home config from
          # scratch (see README.md) has a starting point instead of hand-
          # picking `dotfiles.*` toggles. `base` imports ./modules, so it is
          # the only one an outside consumer strictly needs; the rest layer
          # on top of it.
          #
          # Flat rather than nested under a `profiles` attribute because
          # home-manager's flakeModule types this option as
          # `attrsOf deferredModule`, which collapses a nested set into one
          # module whose `imports` are all five at once.
          base = ./profiles/base.nix;
          dev = ./profiles/dev.nix;
          ai = ./profiles/ai.nix;
          graphical = ./profiles/graphical.nix;
          workstation = ./profiles/workstation.nix;

          # kitty colors, k9s skin, zed settings, and the ai checkout-root
          # doc carry no identity (no username, email, or host-specific
          # value); this flips the four dotfiles.profile.* toggles
          # (modules/profile/) that apply them, so it's exported on its own
          # for an identity that wants the whole bundle without the rest of
          # `home/`. A consumer that wants only one piece can instead set a
          # single dotfiles.profile.<tool>.enable directly against
          # `homeModules.dotfiles`, without this export at all.
          taste = ./home/taste.nix;

          # The whole host file, since the nixos repo's Home Manager NixOS
          # integration wants hades' full configuration (home/ plus the
          # profiles plus hades' own overrides) as a single import; see
          # machines/hades/configuration.nix in that repo.
          hades = ./hosts/hades.nix;
        };

        nixvimModules.default = ./modules/neovim/nixvim-config.nix;

        homeConfigurations =
          let
            inherit (inputs.home-manager.lib) homeManagerConfiguration;
            inherit (inputs.nixpkgs) legacyPackages;

            # `nixpkgs.*` belongs to whoever owns the nixpkgs instance. A
            # standalone home configuration owns its own, so these are set here.
            # Under the Home Manager NixOS module with `useGlobalPkgs`, the
            # system owns it and Home Manager warns that these are ignored, so
            # nothing under `modules/` or the home/profiles/hosts tree may set
            # them; hades gets both
            # from the nixos repo instead.
            common = with inputs; [
              {
                nixpkgs.overlays = [ overlay ];
                nixpkgs.config.allowUnfree = true;
              }
              stylix.homeModules.stylix
              nixvim.homeModules.nixvim
              sops-nix.homeManagerModules.sops
              nix2git.homeModules.nix2git
              { dotfiles.ssh.hosts = hosts.lib.addresses; }
            ];

            # A home configuration with no identity in it: profiles only, plus
            # the account fields Home Manager requires. Nothing from `home/`.
            #
            # No machine is named `generic` and no person is either. These
            # exist so `homeModules.profiles.*` is built here rather than only
            # breaking in whatever flake consumes it, which is the same reason
            # `erik@server` exists. The darwin one is also the only consumer
            # the darwin branches in `modules/` have had since the darwin host
            # was removed.
            generic =
              system: homeDirectory: extraProfiles:
              homeManagerConfiguration {
                pkgs = legacyPackages.${system};
                extraSpecialArgs = { inherit inputs self; };
                modules =
                  common
                  ++ [
                    ./profiles/base.nix
                    ./profiles/dev.nix
                    ./profiles/ai.nix
                  ]
                  ++ extraProfiles
                  ++ [
                    {
                      home = {
                        username = "generic";
                        inherit homeDirectory;
                        stateVersion = "25.05";
                      };

                      # profiles/ai.nix points omnigent at a sops secret that
                      # only `home/` declares, and the module asserts the name
                      # resolves. Identity-free means no secrets, so the
                      # OpenRouter wiring stays off here.
                      dotfiles.ai.omnigent.openRouter.enable = inputs.nixpkgs.lib.mkForce false;
                    }
                  ];
              };
          in
          {
            "erik@darter" = homeManagerConfiguration {
              pkgs = legacyPackages.x86_64-linux;
              extraSpecialArgs = { inherit inputs self; };
              modules = common ++ [ ./hosts/darter.nix ];
            };

            "erik@hades" = homeManagerConfiguration {
              pkgs = legacyPackages.x86_64-linux;
              extraSpecialArgs = { inherit inputs self; };
              modules = common ++ [ ./hosts/hades.nix ];
            };

            # No machine is named `server`. This exists so `hosts/server.nix`
            # is built by `nix flake check` like the other two, rather than
            # being an export that only breaks in whatever flake consumes it.
            "erik@server" = homeManagerConfiguration {
              pkgs = legacyPackages.x86_64-linux;
              extraSpecialArgs = { inherit inputs self; };
              modules = common ++ [ ./hosts/server.nix ];
            };

            "generic@x86_64-linux" = generic "x86_64-linux" "/home/generic" [
              ./profiles/workstation.nix
            ];

            # `workstation` is a Linux desktop session (gnome, brave); darwin
            # takes `graphical` plus the cross-platform GUI tools from it.
            "generic@aarch64-darwin" = generic "aarch64-darwin" "/Users/generic" [
              ./profiles/graphical.nix
              {
                dotfiles = {
                  ghostty.enable = true;
                  helix.enable = true;
                  kitty.enable = true;
                  vscode.enable = true;
                  zed.enable = true;
                };
              }
            ];
          };
      };

      perSystem =
        {
          inputs',
          system,
          pkgs,
          ...
        }:
        {
          packages.nixvim =
            (inputs.nixvim.lib.evalNixvim {
              inherit system;
              modules = [
                { nixpkgs.overlays = [ overlay ]; }
                self.nixvimModules.default
              ];
            }).config.build.package;

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
