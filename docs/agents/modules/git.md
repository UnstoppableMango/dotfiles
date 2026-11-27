# git

## Signing

`git/signing.nix` signs commits (not tags) with `dotfiles.git.signing.key`, an SSH public key by default, which each host sets.
The private half is whatever the host's `dotfiles.ssh.agent` holds.

`dotfiles.git.signing.allowedSigners` comes from `home/git.nix`, every machine's key, and becomes `gpg.ssh.allowedSignersFile`, so a commit signed on one machine verifies on the others.
A bare key verifies as `user.email`; an `{ email, key }` entry is for a key that signs under another email.
An entry also takes `validAfter` and `validBefore` (ssh-keygen's `valid-after`/`valid-before`), which bound the window a key's signatures verify in.

Git checks a signature against the time it was created, so retire a key by moving it out of the host's `signing.key` and into this list with a `validBefore`.
Dropping a key outright unverifies its whole history.

## Local config

`dotfiles.git.localConfig` (`~/.config/git/config.local` by default) is an `include` rendered after every generated section, so a later directive there overrides anything above it.
It holds anything whose existence is not public (a work account's conditional include, a client's credential helper).
Git ignores the include when the file is absent, so nothing creates it.

## opencommit

`git/opencommit.nix` renders the whole of `~/.opencommit` through `sops.templates` when `dotfiles.git.openCommit.apiKeySecret` names a `sops.secrets` entry, because opencommit skips its defaults once that file exists.
The file route rather than `OCO_API_KEY`, since the `prepare-commit-msg` hook also fires for editor and GUI commits that never see a login shell.

- The hook reaches repos through `init.templateDir` rather than a global `core.hooksPath`, because lefthook and similar tools install their hooks into whatever `core.hooksPath` names, which for a global value means every repo.
- The template is a store directory of regular files, since git copies a template symlink as a symlink.
  Its hook execs `~/.config/git/opencommit-hook`, so a copied hook holds no store path and follows the current generation.
- Only repos created after the switch get it; `git init` inside an existing repo adds it without touching hooks already there.
- `dotfiles.git.openCommit.models` seeds `~/.opencommit-models.json` when it is absent or empty, because only `oco models --refresh` writes that file and the package's MODEL_LIST lags the provider API by months.
  It is a discovery aid: opencommit validates `OCO_MODEL` as a string and nothing more.
- `dotfiles.git.openCommit.typeEmoji` has the hook insert an emoji after the Conventional Commit prefix (`feat(git): ✨ ...`).
  `OCO_EMOJI` replaces the conventional-commit prompt with a GitMoji one that drops the type, so an assertion rejects the two together.
- With OpenRouter on, `OCO_TOKENS_MAX_INPUT` is 128000.
  Below that limit oco drafts one message for the whole diff; above it, it drafts one per file chunk and joins them, which puts several title lines in one commit.

## OAuth

`git/oauth.nix` adds git-credential-oauth for each URL in `dotfiles.git.oauth.hosts`.
The helper is set per URL, not globally, because a global oauth helper also starts a browser login for github.com, gitlab.com, and other hosts it knows.
The `cache` helper comes before it, since git-credential-oauth only generates tokens and stores nothing.
A host named `gitea.*` or `forgejo.*` uses the client that Gitea and Forgejo preregister, so it needs no client ID.
