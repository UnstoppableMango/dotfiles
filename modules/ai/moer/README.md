# moer

Mixture-of-Experts code review with mandatory verification: a supervisor agent dispatches 7 specialist reviewers (correctness, security, concurrency, test quality, resilience, performance, policy), 2 passes each, then the calling agent verifies every claim against the actual diff before anything reaches a human.

Credit: [JStoner-SAI](https://github.com/JStoner-SAI) and [Source Allies](https://www.sourceallies.com/), original authors of the skill and its specialist agents.

Wired in via [`../moer.nix`](../moer.nix) (`dotfiles.ai.moer.enable`).
Claude Code only, since it is built on the `task()`/background subagent dispatch mechanism, which Copilot CLI has no equivalent of.
