{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  token = config.dotfiles.github.token;

  url = "https://api.githubcopilot.com/mcp/";

  # The `${...}` is expanded by the reading client, not by nix. Copilot CLI and
  # Claude Code's `github` plugin both do so.
  server = {
    type = "http";
    inherit url;
    headers.Authorization = "Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}";
  };

  # Claude Code runs this on each connect, so a token that rotates under a
  # running session is picked up on reconnect.
  ghAuthHeaders = pkgs.writeShellApplication {
    name = "github-mcp-headers";
    runtimeInputs = [
      config.programs.gh.package
      pkgs.jq
    ];
    text = ''
      jq -n --arg token "$(gh auth token)" '{Authorization: "Bearer \($token)"}'
    '';
  };

  # Exports the token only into the wrapped CLI's process, rather than into
  # every shell. A running session keeps the token it launched with.
  withToken =
    pkg:
    pkgs.symlinkJoin {
      name = "${pkg.pname}-github-token-${pkg.version}";
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${pkg.meta.mainProgram} \
          --run 'export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${token.file})"'
      '';
      # Home Manager picks claude-code's plugin mechanism by version.
      inherit (pkg) meta version;
      passthru = pkg.passthru or { };
    };
in
{
  options.dotfiles.ai.github.ghAuth = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Authenticate Claude Code's GitHub MCP server with `gh auth token`
      through a headersHelper, in place of the `github` plugin and its
      `GITHUB_PERSONAL_ACCESS_TOKEN`. For hosts where gh holds a short-lived
      token, such as a GitHub App installation token.
    '';
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.mcp.servers.github = server;
        programs.github-copilot-cli.mcpServers.github = server;
      }

      (lib.mkIf cfg.github.ghAuth {
        programs.claude-code.mcpServers.github = {
          type = "http";
          inherit url;
          headersHelper = lib.getExe ghAuthHeaders;
        };
      })

      (lib.mkIf (token.secret != null) {
        programs.claude-code.package = lib.mkDefault (withToken pkgs.claude-code);
        programs.github-copilot-cli.package = lib.mkDefault (withToken pkgs.github-copilot-cli);
      })
    ]
  );
}
