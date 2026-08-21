{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # csharp-ls is the modern recommended C# LSP server, but nixpkgs marks it
  # badPlatforms = [ "aarch64-darwin" ] and doesn't build it for x86_64-darwin
  # either, so omnisharp-roslyn (which builds everywhere) is used on Darwin.
  lspPackage = if pkgs.stdenv.hostPlatform.isLinux then pkgs.csharp-ls else pkgs.omnisharp-roslyn;
  lspArgs = if pkgs.stdenv.hostPlatform.isLinux then [ ] else [ "-lsp" ];
  lspCommand = lib.getExe lspPackage;

  extensionToLanguage = {
    ".cs" = "csharp";
  };
in
{
  options.dotfiles.ai.csharp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "C# language support for Claude Code and Copilot CLI: csharp-ls on Linux, omnisharp-roslyn on Darwin (csharp-ls is unsupported there), as the LSP server for .cs files.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.csharp.enable) {
    programs.claude-code.lspServers.csharp = {
      command = lspCommand;
      args = lspArgs;
      inherit extensionToLanguage;
    };

    programs.github-copilot-cli.lspServers.csharp = {
      command = lspCommand;
      args = lspArgs;
      fileExtensions = extensionToLanguage;
    };

    home.packages = [ lspPackage ];
  };
}
