# AGENTS.md

Guidance for AI agents operating anywhere under `~/src`.

This file is a symlink into the Nix store, written by home-manager.
Edit `home/checkout-root.md` in `github.com/UnstoppableMango/dotfiles` and rebuild; edits here will not stick.

`~/src` is not a repository.
It is a checkout root holding ~100 independent git repos.
Nothing here is shared build state, so a change in one repo never affects another except through a published flake input or module version.

`MAP.md`, when present next to this file, is an unmanaged snapshot of the current inventory: owners, stacks, active branches, disk usage.
Treat it as a starting point that may be stale, and confirm anything load-bearing against the tree.

## Layout

The path of a checkout is the path of its remote:

```
~/src/<host>/<owner>/<repo>          git@<host>:<owner>/<repo>
~/src/gitlab.com/unmango/<group>/<repo>   git@gitlab.com:unmango/<group>/<repo>
```

This holds for every repo in the tree, including GitLab, where subgroups add a directory level.
Given `github.com/UnstoppableMango/a2b`, the checkout is at `~/src/github.com/UnstoppableMango/a2b`, with no search needed.
Given a bare repo name, glob `~/src/*/*/<name>` before searching more broadly.

Non-repo directories: `lab/` (scratch projects and a kubeconfig) and `github.com/sourceallies/hack/`.

## Finding things

Resolve a repo by path, not by search.
`~/src` is 60G and a recursive grep or find from the root will read gigabytes of build output and vendored code before reaching anything useful.
`UnstoppableMango/erik` (23G) and `UnstoppableMango/nixos` (17G) together are two thirds of the tree.

Scope every search to a single repo root.
Cross-repo searches are legitimate when the question is genuinely about conventions across repos, but bound them with `--include` or an explicit repo list.

## Owners

| Path                                                                | What it is                                     |
| ------------------------------------------------------------------- | ---------------------------------------------- |
| `github.com/UnstoppableMango`                                       | Main personal namespace                        |
| `github.com/unmango`                                                | Second personal namespace, mostly Go libraries |
| `gitlab.com/unmango`                                                | Personal GitLab, subgroup-nested               |
| `github.com/sourceallies`, `github.com/residex-ai`                  | Work                                           |
| `github.com/crossplane`, `pulumiverse`, `tvanfosson`, `vishvananda` | Upstream clones                                |

In the personal namespaces, `origin` is the user's own repo and is writable.

In an upstream-owner directory, `origin` points at the upstream project, and the personal fork, when one exists, is a separate named remote (for example `UnstoppableMango` in `pulumiverse/pulumi-talos`).
Push to the named fork remote, never to `origin`, and never assume a branch there is the user's to rewrite.

## Per-repo agent instructions

`AGENTS.md` at the repo root is the canonical file.
The Claude and Copilot files are one-line pointers to it, not separate content:

```
CLAUDE.md                        @AGENTS.md
.github/copilot-instructions.md  @../AGENTS.md
```

Read the repo's `AGENTS.md` before making changes in it.
When adding agent instructions to a repo that has none, write `AGENTS.md` and add the pointer files, rather than putting content in `CLAUDE.md`.
A handful of older repos still hold content directly in `CLAUDE.md`; converting one to the pointer form is a welcome cleanup, but do it as its own change.

Repo `AGENTS.md` files follow a loose shape: a short statement of what the repo is, a `## Commands` section, and an `## Architecture` section explaining the directory split and the reasoning behind non-obvious choices.
`github.com/UnstoppableMango/dotfiles/AGENTS.md` is the fullest example of the house style.

Repo-local `.claude/skills/` holds skills scoped to that repo.
`.claude/worktrees/` is agent scratch space and is not tracked.

## Entry points

Check in this order before inventing a command:

1. `Makefile` at the repo root (~80 repos). Common targets: `build`, `test`, `check`, `lint`, `tidy`, `update`, `fmt`, `clean`, `watch`.
2. `.envrc` with `use flake` (~70 repos). The dev shell supplies the toolchain, so run `direnv allow` or `nix develop` rather than reaching for system binaries.
3. `flake.nix` (~70 repos). Nix is the dominant thread across the tree; `nix flake check` and `nix fmt` work in most of them.

Several Makefiles use `.make/<target>` sentinel files to track work that has no natural output file.
Deleting `.make/` forces those steps to rerun.

Some Go repos wrap their tooling in `devctl` (`github.com/unmango/devctl`), invoked from the Makefile.

## Language conventions

Go module paths use the lowercase owner (`github.com/unstoppablemango/tdl`) while the GitHub org and therefore the directory is `UnstoppableMango`.
The directory path and the import path differ in case.
Take import paths from `go.mod`, not from the filesystem.

.NET and F# repos use PascalCase repo names (`CliWrap.FSharp`, `UnMango.Extensions.CommandLine`); everything else is kebab-case or a single lowercase word.

Formatting is per-repo, usually `treefmt` driven by `nix fmt` or a `make fmt` target.
Do not apply a formatter the repo has not configured.

## CI and releases

`.github/workflows/ci.yml` is the standard name for the main workflow.
Repos that publish artifacts add `release.yml`, `release-please.yml`, or `goreleaser.yml`.

Where a `release-please` workflow exists, versions and CHANGELOG entries are generated.
Do not hand-edit them.

`pr-title.yml`, where present, enforces Conventional Commits on the PR title.

## Cross-repo relationships

A few repos depend on each other as flake inputs, so a change in one is not visible to the other until it is committed and pushed:

- `UnstoppableMango/dotfiles` is home-manager config; `UnstoppableMango/nixos` is the system config and imports the dotfiles home modules.
- `UnstoppableMango/hosts` publishes the host address table consumed by both.
- `unmango/go`, `unmango/aferox`, and `unmango/go-make` are libraries consumed by the Go repos in both namespaces.

When a fix spans two of these, land it in the dependency first, then bump the input downstream.
