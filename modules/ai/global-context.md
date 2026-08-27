# Global agent instructions

Personal preferences and instructions for AI coding agents (Claude Code, GitHub Copilot CLI) across all projects.

- Never use the em dash character (U+2014). Use a comma, period, or parentheses instead.
- In markdown files, put each sentence on its own line. Let the renderer wrap text; don't hard-wrap manually.

## English style

- Avoid flourish. State things plainly rather than reaching for a dramatic or literary phrasing.
- Avoid cliche and idiom (e.g. "game-changer," "at the end of the day," "circle back"). Say the literal thing instead.
- Avoid intensifiers ("very," "really," "incredibly," "significantly") unless a number or comparison backs them up.
- Minimize tricolon repetition, the "X, Y, and Z" rhythm used for rhetorical effect (e.g. "robust, scalable, and secure"). Use it only when all three items carry distinct information.
- Avoid negative contrastive phrasing ("not just X, but Y," "it's not about X, it's about Y"). State the positive claim directly.

## Commit and PR conventions

Use Conventional Commits prefixes (`feat:`, `fix:`, `chore:`, `deps:`, `docs:`, `ci:`) for commit subjects and PR titles, matching the convention already used across all my repos.

In repos using release-please (a `chore(main): release ...` PR appears in history), never hand-edit version numbers or CHANGELOG entries; let the release-please PR handle it.

## Bug fixing and review

When a review or debugging session turns up multiple distinct bugs, file one focused GitHub issue per bug rather than a single catch-all issue, and land each fix as its own scoped PR rather than bundling unrelated fixes together. For larger multi-part work, consider the `gh-stack` skill to split it into a reviewable stack.

## Docs and comments

Avoid temporal or narrative language in docs and code comments (e.g. "now", "previously", "this was changed to", "recently added"). Describe the current state only, as if it always existed. This avoids doc/comment rot and repeated cleanup passes.

## Nix

Prefer `inherit (foo) bar;` over `bar = foo.bar;`.

Reference flake `inputs` only inside `flake.nix`.
The same goes for the `self` argument.
Everything else (home-manager modules, NixOS modules, packages, overlays) takes what it needs as explicit arguments or module options, so it stays usable outside the flake that defines it.

This restriction is relaxed for flake modules (`flake-parts` modules and anything else evaluated as part of the flake outputs), where `inputs` and `self` are part of the module arguments by design.

Any deviation needs a justification stated in the code or the PR.

## Shell autoload issue

zsh with Prezto registers system commands (`make`, `diff`, and others) as autoloaded wrapper functions.
Shell snapshots captured by agents include `builtin autoload -XUz` stubs for these commands.
The stubs shadow the real binaries and fail in the subprocess with errors like `(eval):1: make: function definition file not found`, since the subprocess lacks the original `fpath`.
See https://github.com/anthropics/claude-code/issues/46856 for details.
Work around it by prefixing the affected command with `command`, for example `command make`.
