{
  pkgs,
  lib,
  config,
  ...
}:
let
  appDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Application Support/Code"
    else
      "${config.xdg.configHome}/Code";

  # The default profile stores its state in User/globalStorage rather than
  # under User/profiles.
  namedProfiles = lib.remove "default" (lib.attrNames config.programs.vscode.profiles);
in
{
  options.dotfiles.vscode.enable = lib.mkEnableOption "VSCode";

  config = lib.mkIf config.dotfiles.vscode.enable {
    # VS Code creates <profile>/globalStorage as part of initializing a profile
    # directory, and only when that directory is absent. Home Manager links a
    # profile's settings in first, so VS Code finds the directory already there,
    # skips the initialization, and then fails to open state.vscdb
    # (SQLITE_CANTOPEN). It falls back to in-memory storage, which drops command
    # palette history, walkthrough progress, and every extension's first-run
    # state on exit.
    # Drop once https://github.com/nix-community/home-manager/pull/9245 lands.
    home.activation = lib.mkIf (namedProfiles != [ ]) {
      vscodeProfileStorage = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run mkdir -p ${
          lib.escapeShellArgs (map (name: "${appDir}/User/profiles/${name}/globalStorage") namedProfiles)
        }
      '';
    };

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
    programs.vscode = {
      enable = true;
      haskell = {
        enable = true;

        # TODO: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.haskell.hie.executablePath
        hie.enable = false;
      };

      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        # Not on the marketplace, from the gossamer package's editorSupport
        # passthru instead.
        extensions = [ pkgs.gossamer.passthru.editorSupport.vscode ];
      };
    };
  };
}
