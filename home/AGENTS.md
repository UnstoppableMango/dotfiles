# home/

erik's instance values: the account, git identity and aliases, vscode's default-profile settings, GNOME dconf, direnv, the sops secrets, and overrides of module defaults.

## Rules

- Declare no `dotfiles.*` options here; they belong in `modules/`.
- Gate every file on the `dotfiles.*` option its module declares, so importing it costs nothing on a host that has the feature switched off.
- When a value would suit any consumer of the flake, move it to `modules/` as an option default and override it here only if erik differs.
- Keep `home/` flat (no `home/<name>/`).
  A second identity lives in its own flake and consumes `homeModules.dotfiles`.

## Files

- `account.nix` carries no identity: `homeDirectory` is `lib.mkDefault "/home/${config.home.username}"`, and it sets no username.
  `hosts/server.nix` imports it directly and sets its own username, since it skips the rest of `home/`.
- `default.nix` imports the rest and supplies `home.username = lib.mkDefault "erik";`, so it can be composed with a different username without a conflicting-definitions error.
  It also sets `dotfiles.openrouter.apiKeySecret` and `dotfiles.github.token.secret`, which turn those modules on.
- `default.nix` and `account.nix` are reached by relative import from host files rather than exported, since nothing outside this repo imports either by name.
- `vscode/hades.nix` is the one file `default.nix` does not import, because that VS Code profile exists on hades alone; `hosts/hades.nix` imports it.
- `git.nix` holds `dotfiles.git.signing.allowedSigners` (see [git](../docs/agents/modules/git.md)).
- `ssh.nix` holds each YubiKey's `sshKey` values (see [security](../docs/agents/modules/security.md#yubikey)).
- `containers/` points `dotfiles.containers.registryCAs` at the-cluster's Nixery with copies of the nixos repo's `modules/pki` CAs.

## Secrets

`secrets/` is encrypted in `.sops.yaml` to erik's darter and hades keys, so one file decrypts on both, and to each YubiKey's PIV slot as a backup that needs the key and its PIN.
`rosequartz.yaml` differs in origin: the admin cert and key are clan-generated in the nixos repo and re-encrypted here, so a rotation there has to be copied over, the same as `modules/kubernetes/rosequartz/ca.crt`.
See [security](../docs/agents/modules/security.md#sops) for the key layout.
