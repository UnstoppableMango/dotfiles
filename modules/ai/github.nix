{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  token = config.dotfiles.github.token;

  # The `${...}` is expanded by the reading client, not by nix. Copilot CLI and
  # Claude Code's `github` plugin both do so.
  server = {
    type = "http";
    url = "https://api.githubcopilot.com/mcp/";
    headers.Authorization = "Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}";
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
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.mcp.servers.github = server;
        programs.github-copilot-cli.mcpServers.github = server;
      }

      (lib.mkIf (token.secret != null) {
        programs.claude-code.package = lib.mkDefault (withToken pkgs.claude-code);
        programs.github-copilot-cli.package = lib.mkDefault (withToken pkgs.github-copilot-cli);
      })
    ]
  );
}
