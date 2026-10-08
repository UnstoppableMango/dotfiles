{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.openrouter;
  inherit (cfg) omnigent;
  inherit (config.dotfiles) ai;

  omnigentHome = "${config.home.homeDirectory}/.omnigent";
  configPath = "${omnigentHome}/config.yaml";

  # OpenRouter has no Responses API, hence `wire_api = "chat"`.
  entry = {
    kind = "key";
    openai = {
      base_url = cfg.baseUrl;
      wire_api = "chat";
      auth_command = "cat ${cfg.apiKeyFile}";
    }
    // lib.optionalAttrs (omnigent.models != { }) { inherit (omnigent) models; };
  }
  // lib.optionalAttrs omnigent.default { default = true; };

  providerFragment = (pkgs.formats.yaml { }).generate "omnigent-providers.yaml" {
    providers.openrouter = entry;
  };
in
{
  options.dotfiles.openrouter.omnigent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Register OpenRouter under `providers.openrouter` in
        `~/.omnigent/config.yaml`. It serves the `openai` family, which the
        codex, opencode, qwen, and openai-agents harnesses consume.
      '';
    };

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Mark the entry `default: true`, making OpenRouter the default for
        every surface it serves: the `openai` family and the `pi` scope. A
        `claude` subscription entry claims the `anthropic` family only, so
        the two coexist. omnigent rejects a config where two providers claim
        the same family.
      '';
    };

    models = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        default = cfg.models.default;
      };
      defaultText = lib.literalExpression "{ default = config.dotfiles.openrouter.models.default; }";
      description = ''
        Role or tier to OpenRouter model id. The `default` entry is consulted
        when an agent spec pins no model of its own.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && omnigent.enable && ai.enable && ai.omnigent.enable) {
    # omnigent owns the rest of this file (`host.host_id`, `config set --global`).
    home.activation.omnigentProviders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg omnigentHome}
      $DRY_RUN_CMD touch ${lib.escapeShellArg configPath}
      $DRY_RUN_CMD ${pkgs.yq-go}/bin/yq -i \
        '.providers.openrouter = load("${providerFragment}").providers.openrouter' \
        ${lib.escapeShellArg configPath}
    '';
  };
}
