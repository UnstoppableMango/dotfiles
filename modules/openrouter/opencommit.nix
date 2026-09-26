{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.openrouter;
  inherit (cfg) opencommit;
  inherit (config.dotfiles) git;
in
{
  options.dotfiles.openrouter.opencommit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "OpenRouter as opencommit's provider, with its key rendered into `~/.opencommit`.";
    };

    model = lib.mkOption {
      type = lib.types.str;
      default = cfg.models.fast;
      defaultText = lib.literalExpression "config.dotfiles.openrouter.models.fast";
      description = "OpenRouter model id opencommit drafts commit messages with.";
    };
  };

  config = lib.mkIf (cfg.enable && opencommit.enable && git.enable && git.openCommit.enable) {
    dotfiles.git.openCommit = {
      apiKeySecret = lib.mkDefault cfg.apiKeySecret;
      settings = {
        OCO_AI_PROVIDER = lib.mkDefault "openrouter";
        OCO_MODEL = lib.mkDefault opencommit.model;

        # Past this limit oco splits the diff per file, drafts a message for
        # each chunk, and joins them, so one commit gets several title lines.
        # Upstream's 4096 is sized for small local models; both tiers here
        # take far more.
        OCO_TOKENS_MAX_INPUT = lib.mkDefault 128000;
      };
    };
  };
}
