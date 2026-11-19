# Global agent instructions

Personal preferences and instructions for AI coding agents (Claude Code, GitHub Copilot CLI, Crush) across all projects.

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

- When you explain a concept, prefer ASD-STE100 Simplified Technical English: short sentences, one idea per sentence, active voice, and one meaning per word. Technical names (commands, APIs, file paths) are exempt from the vocabulary rules.
- Avoid flourish. State things plainly rather than reaching for a dramatic or literary phrasing.
- Avoid cliche and idiom (e.g. "game-changer," "at the end of the day," "circle back"). Say the literal thing instead.
- Avoid intensifiers ("very," "really," "incredibly," "significantly") unless a number or comparison backs them up.
- Minimize tricolon repetition, the "X, Y, and Z" rhythm used for rhetorical effect (e.g. "robust, scalable, and secure"). Use it only when all three items carry distinct information.
- Avoid negative contrastive phrasing ("not just X, but Y," "it's not about X, it's about Y"). State the positive claim directly.
- Avoid the redundant "own" after a possessive ("nixpkgs' own", "this repo's own", "clan's own"). The possessive already carries the ownership: write "nixpkgs'", "this repo's", "clan's".

## Code Comments

- Default to no comment. Code shows _how_; comment only to carry _why_ — a non-obvious constraint, deliberate deviation, gotcha, or workaround.
- Never narrate the code ("loop over users", "parse the body"), restate names/types/signatures, or mark block ends.
- Never narrate the change ("fixed X", "updated to Y", "as requested"). A comment must read correctly to someone seeing the file fresh who never saw the diff; change context belongs in the commit message.
- Delete by default. A comment that just restates a decision the code already reflects — "1 vCPU is deliberate", "right-sized from prod" — is dead weight even when it points to a doc: the doc is where anyone questioning it looks anyway. Keep inline only what a reader needs _at that line_ and can't get from the code — a non-obvious invariant/constraint ("timeout must stay < interval — ALB rule") or a cross-file sync obligation ("keep in sync with the router's TGs").
- Comments must stand on their own with any link removed — encode the substance, never a pointer as a substitute for it. Banned: specs, section numbers, design docs — point-in-time artifacts that get superseded and rot ("spec §7" is the canonical case). Fine: a maintained doc/README at a stable path — and when the _why_ is a system-level narrative ("why it's built this way"), extract it there as a _pure_ extraction: not an inline block, and not a comment that merely points to the doc. What stays inline are the non-obvious local details, which reference the doc only when a reader genuinely needs it _at that line_ — a pointer-only comment generally shouldn't exist at all. Tickets, Confluence, RFCs, permalinks stay fine as trailing breadcrumbs.
- Occam's razor on every comment you _keep_, not just the ones you delete. "Carries a real _why_" and "is worded minimally" are independent judgments — a genuine _why_ can still be 3x too long, and "it's a real why" is not license to keep the wording verbatim. Keep only the one non-obvious fact a reader needs _at that line_, in the fewest words; cut the mechanism the code already shows, where a value is consumed downstream, the consequence-of-the-consequence, and justification-of-the-justification. A 5-line block almost never survives intact — suspect it on sight; the razored answer is sometimes zero.
- A one-line summary on a public function/endpoint is fine; inline restatement of a single clear line never is.
- TODOs are fine and don't need issue IDs — but a TODO is a marker, not a substitute for doing the work in scope.

## Commit and PR conventions

Use Conventional Commits prefixes (`feat:`, `fix:`, `chore:`, `deps:`, `docs:`, `ci:`) for commit subjects and PR titles, matching the convention already used across all my repos.

In repos using release-please (a `chore(main): release ...` PR appears in history), never hand-edit version numbers or CHANGELOG entries; let the release-please PR handle it.

## Shell autoload issue

zsh with Prezto registers system commands (`make`, `diff`, and others) as autoloaded wrapper functions.
Shell snapshots captured by agents include `builtin autoload -XUz` stubs for these commands.
The stubs shadow the real binaries and fail in the subprocess with errors like `(eval):1: make: function definition file not found`, since the subprocess lacks the original `fpath`.
See https://github.com/anthropics/claude-code/issues/46856 for details.
Work around it by prefixing the affected command with `command`, for example `command make`.
