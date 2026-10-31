# tz: first login on hades

tz is the work account on hades.
`hosts/tz-hades.nix` here holds its tools, https://github.com/erasmussen-tz/dotfiles adds the identity, and the nixos repo holds the system side (the account, zsh, the 1Password app, Tailscale).
What follows is the part no configuration can do: deploying, then signing in.

## Deploy

1. From erik, deploy the nixos change: `clan machines update hades` (hades sets `requireExplicitUpdate`).
2. Log out of erik and log in as tz at the GDM login screen, in GNOME.
3. Switch tz's home from the work flake:

   ```sh
   home-manager switch -b hm-backup --flake github:erasmussen-tz/dotfiles#tz@hades
   ```

   Log out and back in so the zsh login shell and the session variables take effect.

## Sign in

Order matters only at the top: 1Password first, since SSH and git signing go through it.

1. **1Password**: open the app and sign in to the work account.
   In Settings, Developer, turn on "Use the SSH agent" and "Integrate with 1Password CLI".
   Check `ssh-add -l` lists the work key and `op whoami` answers.
2. **Chrome**: sign in to the work Google account, then install the 1Password extension and confirm it unlocks with the app.
   If the extension says the browser is not supported, add `chrome` to `/etc/1password/custom_allowed_browsers` in the nixos repo.
3. **Tailscale**: `tailscale up` and finish in the browser.
   If it asks for sudo, run `sudo tailscale set --operator=tz` once.
   `tailscale down` disconnects; it stays down across reboots.
4. **GitHub**: `gh auth login` (choose SSH, and skip uploading a key if the 1Password one is already on the account).
   Claude Code's GitHub server reads its token from `gh`.
5. **AWS**: `aws sso login --profile <profile>` for each profile erasmussen-tz/dotfiles declares.
6. **Claude Code**: run `claude` and sign in with the work account.
   Slack's MCP server asks to sign in the first time Claude uses it.
7. **Crush**: run `crush`; it reads the OpenRouter key from 1Password, so the app has to be unlocked.
8. **Slack** and **Zoom**: open each and sign in.
9. **VS Code**: `code`, then sign in to GitHub from the accounts menu if Copilot or Settings Sync is wanted.

## Check

- `git commit` in a work repo signs through 1Password (`git log --show-signature -1`).
- `yarn --version` inside a repo with a `packageManager` field prints that version.
- `node --version` follows the repo's `.nvmrc` or `.node-version` (fnm).
