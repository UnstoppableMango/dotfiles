# graphify

`graphify-out/` holds a knowledge graph built from the code alone: every `.nix` file's imports, functions, and `dotfiles.*` options (which module `defines` each, which hosts `configure` it, and which modules `reference` it), plus the Markdown headings.

- Run `graphify query "<question>"` before your first grep, search, or source-file read, and put this rule in every subagent prompt that explores code.
  Read raw files only for lines the graph or an earlier read already located.
- Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts.
  Option nodes are labelled by their full path, such as `dotfiles.ai.enable`.
- Read `graphify-out/GRAPH_REPORT.md` only for broad architecture review, or when query, path, and explain do not surface enough context.
- After changing `.nix` files, run `make graph`.
  Do not use the skill's `/graphify` pipeline: its setup step prefers a PyPI `graphifyy` from `uv` over the dev shell's `graphify` and writes a graph without the `.nix` files.
- `graph.json` and `GRAPH_REPORT.md` are committed and the rest of `graphify-out/` is ignored.
  `graph.json` is rewritten whole on every build, so a large diff to it in a pull request is expected.
- The skill at `.claude/skills/graphify/` is graphify's, installed by `graphify install --project`; reinstall it rather than editing it.
  That command also adds PreToolUse hooks to `.claude/settings.json` and a section to `CLAUDE.md`; drop both.
  Nothing installs graphify's git hooks, so the graph changes only when someone runs `make graph`.
