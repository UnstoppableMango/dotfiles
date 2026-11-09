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
      throw "dotfiles.openrouter: this integration reads the key from a file, so it needs apiKeySecret set; apiKeyCommand covers only Crush."
    else if !(config.sops.secrets ? ${cfg.apiKeySecret}) then
      throw ''dotfiles.openrouter.apiKeySecret names "${cfg.apiKeySecret}", which is not declared in sops.secrets.''
    else
      cfg.apiKeySecret;
in
{
  imports = [
    ./crush.nix
    ./omnigent.nix
    ./opencode.nix
    ./opencommit.nix
    ./zed.nix
  ];

  options.dotfiles.openrouter = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = cfg.apiKeySecret != null || cfg.apiKeyCommand != null;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.apiKeySecret != null || config.dotfiles.openrouter.apiKeyCommand != null";
      description = ''
        OpenRouter as the model provider for every tool with an integration
        under `modules/openrouter/`. Each integration applies when both this
        and its tool are enabled, and has its own `enable` to opt one tool
        out. On whenever `apiKeySecret` or `apiKeyCommand` is set.
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

    apiKeyCommand = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "op read op://Work/OpenRouter/credential";
      description = ''
        Shell command printing the OpenRouter API key, for an identity that
        holds it in a password manager rather than sops. Only integrations
        that run a shell when their tool starts can use it, which today is
        Crush alone; the rest need `apiKeySecret` and default off without it.
        `apiKeySecret` wins when
        both are set.
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
