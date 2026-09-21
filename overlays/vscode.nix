{
  # The editors fetch `onig.wasm` from `node_modules.asar.unpacked`, which the
  # nixpkgs build omits; without it every file renders untokenized.
  overlays.default =
    _final: prev:
    let
      addAsarUnpacked =
        pkg:
        pkg.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            app="$out/lib/vscode/resources/app"
            if [ -d "$app/node_modules" ] && [ ! -e "$app/node_modules.asar.unpacked" ]; then
              ln -s node_modules "$app/node_modules.asar.unpacked"
            fi
          '';
        });
    in
    {
      vscode = addAsarUnpacked prev.vscode;
      vscodium = addAsarUnpacked prev.vscodium;
    };
}
