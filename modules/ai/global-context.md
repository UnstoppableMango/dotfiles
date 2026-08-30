# Global agent instructions

Personal preferences and instructions for AI coding agents (Claude Code, GitHub Copilot CLI) across all projects.

- Never use the em dash character (U+2014). Use a comma, period, or parentheses instead.
- In markdown files, put each sentence on its own line. Let the renderer wrap text; don't hard-wrap manually.

## Asking questions

Ask questions often, and make each one specific.

- Ask as soon as a choice comes up, before writing code that assumes an answer. A question raised after the work is done is too late.
- Ask about one concrete decision at a time: name the file, the option, the tradeoff. Do not ask broad questions like "how should I approach this?"
- List the candidate answers you see, recommendation first, so the reply can be a single word.
- Use the interactive question tool when the harness provides one. Otherwise put the question on its own line at the end of the response.
- Do not ask permission to proceed with work already requested, and do not ask what reading the code would answer. Check first, then ask about what is still open.

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

## Shell autoload issue

zsh with Prezto registers system commands (`make`, `diff`, and others) as autoloaded wrapper functions.
Shell snapshots captured by agents include `builtin autoload -XUz` stubs for these commands.
The stubs shadow the real binaries and fail in the subprocess with errors like `(eval):1: make: function definition file not found`, since the subprocess lacks the original `fpath`.
See https://github.com/anthropics/claude-code/issues/46856 for details.
Work around it by prefixing the affected command with `command`, for example `command make`.
