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
    # VS Code skips creating globalStorage for a profile directory Home Manager
    # already made, then loses state (SQLITE_CANTOPEN).
    # Drop once https://github.com/nix-community/home-manager/pull/9245 lands.
    home.activation = lib.mkIf (namedProfiles != [ ]) {
      vscodeProfileStorage = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        run mkdir -p ${
          lib.escapeShellArgs (map (name: "${appDir}/User/profiles/${name}/globalStorage") namedProfiles)
        }
      '';
    };

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

        extensions = [ pkgs.gossamer.passthru.editorSupport.vscode ];
      };
    };
  };
}
