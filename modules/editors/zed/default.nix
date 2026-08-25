{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.zed.enable = lib.mkEnableOption "Zed";

  config = lib.mkIf config.dotfiles.zed.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zed-editor.enable
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;

      userSettings = {
        # Gossamer isn't a published Zed extension. The extension directory
        # is materialized at ~/.config/zed/dev-extensions/gossamer; run
        # "zed: install dev extension" once, pointing at that path (and
        # again whenever the gossamer package updates, since the target is
        # a nix store path).
        languages.Gossamer.language_servers = [ "gossamer-lsp" ];
        lsp.gossamer-lsp.binary = {
          path = "${pkgs.gossamer}/bin/gos";
          arguments = [ "lsp" ];
        };
      };

      extraPackages = with pkgs; [
        nil
      ];
    };

    xdg.configFile."zed/dev-extensions/gossamer".source = pkgs.gossamer.passthru.editorSupport.zed;
  };
}
