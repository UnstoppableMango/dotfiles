{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.openrouter;
  inherit (cfg) crush;
  inherit (config.dotfiles) ai;
in
{
  options.dotfiles.openrouter.crush = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "OpenRouter as Crush's model provider.";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = cfg.models.default;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.models.default";
      description = "OpenRouter model id for Crush's large slot, which does the agent work.";
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = cfg.models.fast;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.models.fast";
      description = "OpenRouter model id for Crush's small slot, which titles and summarizes sessions.";
    };
  };

  config = lib.mkIf (cfg.enable && crush.enable && ai.enable && ai.crush.enable) {
    # OpenRouter is in Crush's built-in provider catalog, so the key is the
    # only setting it needs. crushrc reads the file each time Crush starts.
    dotfiles.ai.crush.crushrc = ''
      provider add openrouter --api-key "$(cat ${lib.escapeShellArg cfg.apiKeyFile})"
      model large ${lib.escapeShellArg "openrouter/${crush.model}"}
      model small ${lib.escapeShellArg "openrouter/${crush.smallModel}"}
    '';
  };
}
