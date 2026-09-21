{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.openrouter;
  inherit (cfg) zed;
  pkg = pkgs.zed-editor;

  # Zed has no file route for the key, only its keychain or OPENROUTER_API_KEY.
  wrapped = pkgs.symlinkJoin {
    name = "zed-editor-openrouter-${pkg.version}";
    paths = [ pkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${pkg.meta.mainProgram} \
        --run 'export OPENROUTER_API_KEY="$(cat ${cfg.apiKeyFile})"'
    '';
    inherit (pkg) meta;
    # programs.zed-editor.installRemoteServer reads both off the package.
    passthru = pkg.passthru // {
      inherit (pkg) remote_server remoteServerExecutableName;
    };
  };
in
{
  options.dotfiles.openrouter.zed = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        OpenRouter as the Zed agent's model provider. The key reaches Zed
        through a wrapper around `zeditor`; on macOS, launching Zed.app from
        Finder or the Dock bypasses it.
      '';
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = cfg.models.default;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.models.default";
      description = "OpenRouter model id the Zed agent defaults to.";
    };
  };

  config = lib.mkIf (cfg.enable && zed.enable && config.dotfiles.zed.enable) {
    programs.zed-editor = {
      package = lib.mkDefault wrapped;
      userSettings = {
        language_models.open_router.api_url = cfg.baseUrl;
        agent.default_model = {
          provider = "openrouter";
          inherit (zed) model;
        };
      };
    };
  };
}
