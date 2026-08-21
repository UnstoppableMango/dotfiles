# Global agent instructions

Personal preferences and instructions for AI coding agents (Claude Code, GitHub Copilot CLI) across all projects.

- Never use the em dash character (U+2014). Use a comma, period, or parentheses instead.
- In markdown files, put each sentence on its own line. Let the renderer wrap text; don't hard-wrap manually.

## Shell autoload issue

zsh with Prezto registers system commands (`make`, `diff`, and others) as autoloaded wrapper functions.
Shell snapshots captured by agents include `builtin autoload -XUz` stubs for these commands.
The stubs shadow the real binaries and fail in the subprocess with errors like `(eval):1: make: function definition file not found`, since the subprocess lacks the original `fpath`.
See https://github.com/anthropics/claude-code/issues/46856 for details.
Work around it by prefixing the affected command with `command`, for example `command make`.
