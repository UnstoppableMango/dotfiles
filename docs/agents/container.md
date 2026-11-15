# The container image

`generic@container` builds `hosts/container.nix`, the headless, identity-free configuration behind `packages.container` (x86_64-linux only, built by `container.nix` with nix2container).
It runs as the Claude agent in the-cluster's `apps/claude` pod, which supplies a dockerd sidecar, a nix-daemon, a ServiceAccount token, and the user namespace rootless podman runs in.

## Left off

- Every GUI module, plus 1Password (its agent socket belongs to the desktop app), sops (an image holds no age key), and gnupg (pinentry needs a session).
- `dotfiles.ssh.agent = null`, since the image runs no systemd user manager to host an agent.
- Anything interactive, since its output goes to an agent: `dotfiles.zsh.p10kConfig = null`, and no oh-my-zsh, fzf, htop, or less.
- neovim, whose curated LSP set bundles every language server, and every agent CLI other than Claude Code (`ai.copilot`, `ai.crush`, `ai.cursor.cli`, `ai.coderabbit`, `ai.omnigent`, `ai.opencode`).
- `ai.*` integrations that default on but need a display or a toolchain the image lacks (azure, chromeDevtools, playwright, csharp, fsharp, haskell, ocaml).
- For size: helix, the `home-manager` CLI (the image is never activated or switched), `programs.vim` (Home Manager builds it from `vim-full`), the gitMcp and gossamer integrations, and every glibc locale except `en_US.UTF-8`.
- cloudflare, gitlab, and pulumi, which sign in through a browser.
- aws, which nothing in the container uses, and every session would start its own `uvx` proxy at about 160MiB.

## Non-interactive defaults

- `PAGER`, `GH_PAGER`, `MANPAGER`, git's `core.pager`, and gh's `pager` are `cat`, and git's diff-highlight integration is off, since it pipes into less.
- Git's `core.editor` is `true`, so a merge or rebase keeps its default message instead of waiting on nvim.
- Git's `maintenance.auto` and `gc.auto` are off: a commit otherwise detaches `git maintenance run --auto` into a session of its own, which leaves an orphan behind every commit.
- The profile carries tini, which the-cluster runs as PID 1 in front of `claude remote-control`, since remote-control reaps none of the orphans its sessions leave.
- Claude Code's `settings.json` denies the claude.ai connectors that sign in through a browser (Prisma, Stack Overflow, Supabase), and is forced over the copy Claude Code wrote on home volumes from images that left it unmanaged.

## Userland and toolchains

- Coreutils come from uutils (`uutils-coreutils-noprefix`), in the base layer and the profile; the base layer adds `/usr/bin/env` for env-shebang scripts.
- The profile carries the rest of the userland scripts expect (sed, awk, diffutils, findutils, make, tar and the compressors, curl, ssh, procps, which, file, patch, rsync).
- Toolchains: c, go, python, rust, nix, and dotnet with SDKs 8 and 10 (`dotfiles.dotnet.sdks`).
  Node comes from `pkgs.nodejs`, which several `ai.*` modules install, rather than the javascript module's fnm, plus bun and yarn.
- `home.packages` lists the CLIs the owner's repositories use outside a devShell (buf, dprint, golangci-lint, goreleaser, kind, kustomize, kubeseal, opentofu, pulumi, sops, and similar).
- `dotfiles.containers` is on with clients only (`tui = false`, `userRegistryConfig = true`), and `containers.conf` sets the cgroupfs manager, `cgroups = "disabled"`, and a file event logger, since the pod has no systemd and delegates no cgroup to the user.
- `dotfiles.kubernetes` is on with k9s off; kubectl finds the in-cluster token without a kubeconfig.

## Home files at start

Nothing in `/home/generic` is baked in, so `$HOME` can be a volume that keeps state across restarts (the-cluster mounts a PVC there).
The entrypoint places home files at every start with putter, Home Manager's alternative file activator, which needs no nix; the full `activate` script cannot run, since it calls `nix-build` and `nix-env`.
Putter reads `home.internal.filePutterConfig` and keeps state in `~/.local/state/home-manager/putter-state.json`, so a file a later image drops is removed and every other file in `$HOME` is left alone.
A regular file at a managed path fails the start, as `home-manager switch` does without `-b`.
Kubernetes callers pass their command as `args`, because `command` replaces the entrypoint.
`home.path/bin` is on `PATH`.
