{ ... }:
{
  # Agent CLIs and their MCP wiring. Separate from `dev` because a host can be
  # a full development machine without one, and because the omnigent server
  # needs a decryptable OpenRouter secret that not every host has.
  dotfiles.ai = {
    enable = true;
    omnigent.openRouter = {
      enable = true;
      apiKeySecret = "openrouter-api-key";
    };
  };
}
