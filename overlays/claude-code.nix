# nixpkgs tracks a claude-code release a few versions behind, and the older CLI
# has no entry for claude-opus-5-5. Overriding the manifest points the existing
# derivation at a newer release; drop this once nixpkgs catches up.
{
  overlays.default = final: prev: {
    claude-code = prev.claude-code.override {
      manifest = prev.lib.importJSON ./claude-code-manifest.zst.json;
    };
  };
}
