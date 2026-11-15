# ssh, gnupg, onepassword, sops, yubikey, github token

## ssh

- Host aliases come from the `hosts` flake input (https://github.com/UnstoppableMango/hosts) as `dotfiles.ssh.hosts`, which `hosts/common.nix` sets.
- `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
- `dotfiles.ssh.agent` names the one SSH agent a machine uses (`openssh`, `gnome`, `1password`, or null), since every agent claims `SSH_AUTH_SOCK`.
  `gnome` means the system's `gcr-ssh-agent`, which exports nothing, so the module sets `SSH_AUTH_SOCK` through Home Manager's `sshAuthSock`.
  hades uses `gnome` so the passphrase-protected key unlocks with the login keyring; darter and server use `openssh`; macOS defaults to null because launchd runs an agent.
- `dotfiles.ssh.primaryIdentityFile` (`~/.ssh/id_ed25519` by default) is offered first, and `dotfiles.ssh.identityFiles` is the additive list after it, which `modules/yubikey/` fills.
  They are split because a list option keeps only the definitions at the winning priority, so a host naming its key in `identityFiles` would discard the YubiKey handles.
  Both feed one `IdentityFile`, unset when empty, because an explicit `IdentityFile` stops ssh from trying its defaults.
  `primaryIdentityFile = null` leaves the key path to a block in `~/.ssh/config.d/`; darter does this.

## gnupg

gpg and gpg-agent for signing and encryption only; gpg-agent never serves SSH.
`dotfiles.gnupg.pinentry` picks the prompt: `pinentry-gnome3` on Linux, `pinentry_mac` on macOS, `pinentry-curses` on server.

## onepassword

The 1Password CLI, plus the agent socket when a host sets `dotfiles.ssh.agent = "1password"`, in which case git signs through the app's `op-ssh-sign`, since 1Password keys never reach `ssh-keygen`.
The desktop app owns the socket and is not installable from nixpkgs on macOS, so the module points at an app installed by hand.
Only `hosts/generic.nix` enables it, so both platforms' socket paths are built.

## sops

The age key lives at `~/.config/sops/age/keys.txt` (`dotfiles.sops.keyFile`), which holds only software identities, since sops-nix reads it unattended.
YubiKey identities live in `~/.config/sops/age/yubikey.txt` (see `docs/yubikey.md`).

## yubikey

ykman, yubico-piv-tool, libfido2, and yubikey-personalization, with Yubico Authenticator behind `dotfiles.yubikey.gui` (Linux only), and age-plugin-yubikey when sops is on.

- `dotfiles.yubikey.keys.<name>.sshKey` records each key's resident FIDO2 SSH credential (values in `home/ssh.nix`), and ssh offers that key's `handle`.
  `application` identifies the credential on the authenticator and is fixed at creation; `handle` is only a path, which ssh reads by content.
  `handle` defaults to the name `ssh-keygen -K` derives from `application` (`ssh:<name>` gives `~/.ssh/id_ed25519_sk_rk_<name>`, bare `ssh:` gives `~/.ssh/id_ed25519_sk_rk`); anything else means renaming the downloaded file by hand.
- An assertion catches two available keys offering one handle, since ssh skips a missing handle silently.
- When gpg is on, scdaemon uses `disable-ccid` and `pcsc-shared`, so ykman keeps working alongside gpg-agent.
- `pcscd` and the udev rules are system services: the nixos repo supplies them on hades, and darter needs the distribution packages.
- `docs/yubikey.md` is the onboarding runbook.

## github token

A GitHub personal access token in sops, for the GitHub MCP server.
`dotfiles.github.token.secret` names a `sops.secrets` entry and turns the module on.
GitHub has no API for creating a PAT, so rotation keeps one manual step.

- A daily `github-token-expiry` user timer reads the `github-authentication-token-expiration` header and sends `notify-send` inside `warnDays` of expiry or on a 401.
- `github-token-rotate` reads a new token from stdin, checks it against the API, and writes it into the sops file in `dotfiles.homeManager.flakePath` with `sops set`.
- `docs/github-token.md` is the rotation runbook.
