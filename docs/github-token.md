# GitHub MCP token

The GitHub MCP server (`https://api.githubcopilot.com/mcp/`) authenticates with a fine-grained personal access token stored in `home/secrets/github.yaml` under `github_pat`.
`modules/github/` decrypts it with sops-nix, and `modules/ai/github.nix` exports it as `GITHUB_PERSONAL_ACCESS_TOKEN` into `claude` and `copilot` when they launch.

## Token settings

- Resource owner: your account. Create a second token only if an org requires its own approval.
- Repository access: all repositories.
- Permissions: read access to metadata, contents, issues, and pull requests. Add write access for anything the agents should change.
- Expiration: up to one year. The expiry check reads the date from GitHub, so nothing in nix records it.

## Rotating

1. Run `github-token-rotate`. It opens the token creation page and prompts for the new token without echoing it.
2. The script checks the token against `api.github.com/user`, then writes it into the sops file with `sops set`.
3. Run `homeup` (or `make home`) so sops-nix decrypts the new value.
4. Restart open `claude` and `copilot` sessions, and `systemctl --user restart claude-remote-control` where it runs. A session keeps the token it launched with.
5. Revoke the old token at https://github.com/settings/personal-access-tokens.
6. Commit `home/secrets/github.yaml`.

## Expiry check

`github-token-expiry.timer` runs daily.
It logs the expiry date to the journal and sends a desktop notification once fewer than `dotfiles.github.token.warnDays` (14) days remain, or when GitHub rejects the token.
Run it by hand with `systemctl --user start github-token-expiry` and read the result with `journalctl --user -u github-token-expiry -n 5`.

The committed `home/secrets/github.yaml` starts as a placeholder, so the check reports a 401 until the first `github-token-rotate`.
