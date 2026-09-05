{
  # VS Code's release build fetches `onig.wasm` from
  # `node_modules.asar.unpacked/vscode-oniguruma/release/onig.wasm`, and the
  # nixpkgs build ships `node_modules` and `node_modules.asar` without that
  # directory. The fetch fails, oniguruma never loads, TextMate tokenization
  # never initializes, and every file in the editor renders as plain text.
  # `node_modules` holds the same packages, so pointing the missing path at it
  # satisfies every fetch the built product makes.
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
    };
}
