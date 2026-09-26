{ inputs }:
let
  inherit (inputs.nixpkgs.lib) composeManyExtensions;

  claude-code = import ./overlays/claude-code.nix;
  clan = import ./overlays/clan.nix { inherit (inputs) clan-core; };
  slip = import ./overlays/slip.nix { inherit (inputs) slip; };
in
composeManyExtensions (
  with inputs;
  [
    devctl.overlays.default
    mangopkgs.overlays.default
    nil.overlays.default
    nix-direnv.overlays.default
    nix-vscode-extensions.overlays.default
    # Composes gomod2nix's overlay in
    tdl.overlays.default
    claude-code.overlays.default
    clan.overlays.default
    slip.overlays.default

    # cargo-about pin conflict is resolved upstream (zed's own nix/build.nix
    # now vendors cargo-about via fetchFromGitHub), but a new mismatch surfaced:
    # nixpkgs' livekit-libwebrtc is out of sync with zed 0.217.3's expected
    # webrtc API (`no type named 'AudioDeviceSink' in namespace 'webrtc'`).
    # zed.overlays.default
  ]
)
