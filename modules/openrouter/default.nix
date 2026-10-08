{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.openrouter;

  # Replaces an attribute-missing error from inside sops.secrets.
  secret =
    if cfg.apiKeySecret == null then
      throw "dotfiles.openrouter.enable needs apiKeySecret set: every integration authenticates with it."
    else if !(config.sops.secrets ? ${cfg.apiKeySecret}) then
      throw ''dotfiles.openrouter.apiKeySecret names "${cfg.apiKeySecret}", which is not declared in sops.secrets.''
    else
      cfg.apiKeySecret;
in
{
  imports = [
    ./omnigent.nix
    ./opencode.nix
    ./opencommit.nix
    ./zed.nix
  ];

  options.dotfiles.openrouter = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.apiKeySecret != null;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.apiKeySecret != null";
      description = ''
        OpenRouter as the model provider for every tool with an integration
        under `modules/openrouter/`. Each integration applies when both this
        and its tool are enabled, and has its own `enable` to opt one tool
        out. On whenever `apiKeySecret` is set.
      '';
    };

    apiKeySecret = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Name of a `sops.secrets` entry holding the OpenRouter API key. The
        declaration itself is identity-scoped, so it lives under `home/`;
        this module only names it.
      '';
    };

    models = {
      default = lib.mkOption {
        type = lib.types.str;
        default = "anthropic/claude-sonnet-5";
        description = "OpenRouter model id for general-purpose work: agents and editor chat.";
      };

      fast = lib.mkOption {
        type = lib.types.str;
        default = "anthropic/claude-haiku-4.5";
        description = "OpenRouter model id for short, cheap requests: commit messages, titles, summaries.";
      };
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "https://openrouter.ai/api/v1";
      description = "OpenRouter's OpenAI-compatible endpoint, for integrations to read.";
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = config.sops.secrets.${secret}.path;
      defaultText = lib.literalExpression "config.sops.secrets.\${config.dotfiles.openrouter.apiKeySecret}.path";
      description = ''
        Decrypted key path, for integrations whose tool reads a file or runs a
        command. Keeps the key out of the nix store and the environment.
      '';
    };

    apiKeyPlaceholder = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = config.sops.placeholder.${secret};
      defaultText = lib.literalExpression "config.sops.placeholder.\${config.dotfiles.openrouter.apiKeySecret}";
      description = "sops-nix placeholder for the key, for integrations that render a `sops.templates` file.";
    };
  };
}
