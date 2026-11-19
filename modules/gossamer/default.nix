{ lib, ... }:
{
  options.dotfiles.gossamer.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Gossamer language support in every enabled editor and agent: the `gos`
      language server, the editor plugins from the package's `editorSupport`
      passthru, and the agent skill. Set false to keep `pkgs.gossamer`, and
      the LLVM toolchain it pulls in, out of the closure.
    '';
  };
}
