# ai and openrouter

## modules/ai/

claude-code, github-copilot-cli, cursor-cli, and crush.
Each MCP integration and third-party service (aws, azure, cloudflare, figma, slack, gossamer, per-language servers) gets its own `.nix` toggle file.
`moer/`, `nix-skill/`, and `tdd-orchestrator/` are skill submodules (a SKILL.md plus agents).

- `global-context.md` is the user-level agent instructions, rendered to `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md` and loaded by Crush as a global context path.
  `.claude/skills/agent-context/` covers how to change it.
- `checkout-root.nix` renders `checkout-root.md` to `~/src/AGENTS.md` with a `CLAUDE.md` include beside it, so conventions spanning the whole checkout root are stated once.
  The document is `dotfiles.ai.checkoutRoot.context`; a consumer supplies their own or sets it to null.
- `omnigent.nix` installs omnigent and runs its server and host daemon; its model provider comes from `openrouter/omnigent.nix`.
- `github.nix` wraps `claude` and `copilot` to export `GITHUB_PERSONAL_ACCESS_TOKEN` from the decrypted token file at launch, since both the Claude `github` plugin and Copilot CLI expand that variable in the server's `Authorization` header.
  The remote-control unit runs the wrapped `claude` through `finalPackage`.
- `mattpocock.nix` installs https://github.com/mattpocock/skills from `dotfiles.ai.mattpocock.src`.
  Copilot CLI's skill list is read from that checkout's `.claude-plugin/plugin.json`, the same list the Claude Code plugin loads.

### coderabbit.nix

Installs the CodeRabbit CLI from `mangopkgs` and turns its self-update off, since `coderabbit update` rewrites the binary in place and a nix-installed one lives in the read-only store.
Authentication is a rendered `~/.coderabbit/auth.json` (`{"type":"api_key",...}`), because the CLI reads no `CODERABBIT_API_KEY`.
Its api_key branch returns that file verbatim instead of consulting the OS credential store, so the file alone is a complete authenticated state.
The key comes from `dotfiles.ai.coderabbit.apiKeySecret`, and it has to be an agentic key; the CLI rejects a user API key.

### crush.nix

Writes `~/.config/crush/crushrc`, the Bash config Crush prefers over its deprecated `crush.json`, from `dotfiles.ai.crush.crushrc` (`lines`), which other modules append to.
It carries over what the other agents get rather than declaring a third set: an `lsp add` per `programs.claude-code.lspServers` entry, an `mcp add` per `programs.mcp.servers` entry, and `global-context.md`.

- MCP values are double-quoted, because the `${VAR}` references in `programs.mcp.servers` are left for the client to expand, and in a crushrc that client is a shell.
  `github.nix` sets `GITHUB_PERSONAL_ACCESS_TOKEN` at the top of the file.
- Crush starts a browser sign-in only for a server marked `--oauth`, and a marked server will not connect until it has a token, so `dotfiles.ai.crush.oauthServers` names the ones that need it.
- Crush reads `~/.claude/skills` by default; `mattpocock.nix` and `adhd.nix` add their plugin-only skills with `option skill-path`.

## modules/openrouter/

OpenRouter is the one provider for every paid model outside Claude Code.
Claude Code stays on the Claude subscription, since Remote Control refuses an `ANTHROPIC_BASE_URL` other than api.anthropic.com.

`dotfiles.openrouter` turns on when `dotfiles.openrouter.apiKeySecret` names a `sops.secrets` entry, which only `home/` does.
`default.nix` holds the key and two model tiers (`models.default`, `models.fast`), and exposes read-only `baseUrl`, `apiKeyFile`, and `apiKeyPlaceholder`.
Each tool gets one file declaring `dotfiles.openrouter.<tool>.enable` (on by default) plus a model option defaulting to a tier, active only when OpenRouter and the tool are both enabled.
Adding a tool means adding a file and listing it in `default.nix`'s `imports`.

- `omnigent.nix`: `~/.omnigent/config.yaml` is runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only `providers.openrouter` and leaves every sibling key alone.
  Its `auth_command` reads the key file, since the systemd user unit never sees a login shell.
- `crush.nix`: adds `provider add openrouter --api-key "$(cat ...)"` to the crushrc and fills the large and small model slots from the two tiers.
- `opencode.nix`: passes the key as `{file:...}`, which opencode resolves when it loads its config.
- `opencommit.nix`: sets `dotfiles.git.openCommit`'s key, provider, and model at `mkDefault`, and raises `OCO_TOKENS_MAX_INPUT` to 128000 (see [git](git.md#opencommit)).
- `zed.nix`: wraps `zeditor` to export `OPENROUTER_API_KEY` at launch, because Zed has no file route for the key.
  On macOS, launching Zed.app from Finder bypasses the wrapper.
