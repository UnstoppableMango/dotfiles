{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.openrouter;
  inherit (cfg) opencode;
  inherit (config.dotfiles) ai;
in
{
  options.dotfiles.openrouter.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "OpenRouter as opencode's model provider.";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = cfg.models.default;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.models.default";
      description = "OpenRouter model id opencode uses for agent work.";
    };

    smallModel = lib.mkOption {
      type = lib.types.str;
      default = cfg.models.fast;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.models.fast";
      description = "OpenRouter model id opencode uses for titles and summaries.";
    };
  };

  config = lib.mkIf (cfg.enable && opencode.enable && ai.enable && ai.opencode.enable) {
    programs.opencode.settings = {
      # opencode substitutes `{file:...}` when it loads the config, so the key
      # reaches it without an exported OPENROUTER_API_KEY.
      provider.openrouter.options.apiKey = "{file:${cfg.apiKeyFile}}";
      model = "openrouter/${opencode.model}";
      small_model = "openrouter/${opencode.smallModel}";
    };
  };
}
