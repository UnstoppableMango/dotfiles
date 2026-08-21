---
name: tdd-orchestrator
description: Strict red/green/refactor TDD loop driven by three isolated subagents. Use when the user asks to implement a feature test-first or explicitly requests TDD.
---

# TDD Orchestrator

You coordinate a strict red/green/refactor TDD loop across three isolated
subagents. You are _only_ a coordinator. Three subagents do the actual
work, each in its own context window.

## You do not write code

The single most important rule: **you never create, edit, read, or run
source or test files yourself.** Every phase goes to a subagent via the
Task tool. If you catch yourself about to use Write, Edit, or Bash to
touch source or test files in the target repo, stop — that's a phase you
should have dispatched.

Exceptions (these are yours, not the subagents'):

- Read the **target repo's** `AGENTS.md` once at the start to pick up
  project conventions.
- Read the user's feature description.
- Manage phase handoffs and report back to the user.

## Dispatch mechanism

`tdd-red`, `tdd-green`, and `tdd-refactor` are **subagents** (defined
in `.github/agents/*.agent.md`), not skills. You invoke them with the
**Task** tool.

**Do not use the Skill tool to invoke `tdd-red`, `tdd-green`, or
`tdd-refactor`.** They are not skills — the Skill tool will return
"Unknown skill". The only skill involved in this workflow is this one
(`tdd-orchestrator`), which you are already running.

Correct invocation shape:

````
Task(
  subagent_type: "tdd-red",
  description: "Red phase — <behavior name>",
  prompt: '''
  ```json
  {
    "target_repo": "/Users/you/dev/project",
    "feature_spec": "...",
    "target_module": "...",
    "test_framework": "...",
    "test_path_pattern": "...",
    "test_runner_command": "...",
    "existing_files": [...]
  }
  ```

  Any free-text context the subagent should know.
  '''
)
````

Each subagent returns a fenced JSON block matching its output contract
plus a prose summary. Extract the JSON from the tool result, record
the fields you'll need for the next phase, and proceed.

## Loop

### Step 0 — Target and conventions

Determine the target repo's absolute path. If the user didn't say, ask.
Read `<target_repo>/AGENTS.md` for the project's language, test
framework, path patterns, and test runner command. If the target repo
has no `AGENTS.md`, ask the user for these values before proceeding.

### Step 1 — Decompose

List the behaviors the feature implies, one per line, in an order you
think will let each new test force new production code when its turn
comes. Confirm the list with the user unless they've already supplied
an explicit ordered list.

Heuristic for ordering: start with the most degenerate or fundamental
case (empty input, zero, null, absence) and work toward specifics. Per
Kent Beck's triangulation approach, each test in the sequence should
ideally push the implementation toward a more general shape than the
last. You won't always get this right — when a test passes
immediately against current impl, that's a signal to reorder or to
keep the test as a pin-down (see rules below).

**Include boundary behaviors when the feature names numeric
thresholds.** If the ticket or your decomposition involves thresholds
("at 80%", "past 2×", "within N days", "more than X"), add explicit
behaviors for the exact boundary and the first unit past it. These
may not drive new code, but they document the contract and guard
against off-by-one regressions. Rule of thumb: for every threshold,
include at least one behavior for "exactly at the threshold" and one
for "just past the threshold."

Example — "Is a pet overdue for a checkup?" might decompose to:

1. No visits → overdue
2. Visit older than interval → overdue
3. Recent visit within interval → not overdue
4. Exactly on interval boundary → not overdue
5. Multiple visits, most recent wins

Note: this list is a plan, not a taxonomy. Some of these behaviors
will force new code; others will pass as a side-effect of earlier
implementations and remain as regression guards. That's expected —
the rules handle both cases.

### Step 2..N — Run the loop

For each behavior, in order:

1. **Red**: dispatch `tdd-red` with the behavior spec. The subagent
   commits the new test automatically on confirmed failure.
2. **Green**: dispatch `tdd-green` with the test paths from Red's output.
   The subagent commits the implementation automatically on passing.
3. **Refactor**: dispatch `tdd-refactor` with test + impl paths.
4. Report a one-paragraph summary of all three phases to the user,
   then proceed to the next behavior without pausing. Only stop
   between behaviors if a rule below requires it (test passed
   immediately, Green failed repeatedly, Refactor broke tests, or a
   scope-ambiguous escalation per the escalation-handling rule
   below).

When the loop finishes, run the full test suite to confirm nothing
regressed and report the final state to the user.

## Payload contracts

### Red — input (orchestrator → subagent)

```json
{
	"target_repo": "/absolute/path/to/project",
	"feature_spec": "plain-language description of this one behavior",
	"target_module": "absolute path where impl will live",
	"test_framework": "e.g. pytest, vitest, junit5",
	"test_path_pattern": "e.g. src/test/java/**",
	"test_runner_command": "e.g. ./mvnw test",
	"existing_files": ["absolute paths the subagent may read for context"]
}
```

### Red — output (subagent → orchestrator)

```json
{
	"test_files_written": ["absolute paths"],
	"assertions_summary": ["one line per assertion"],
	"confirmed_failing": true,
	"stub_files_touched": ["absolute paths of empty stubs, if any"],
	"notes": "anything surprising or escalated"
}
```

### Green — input

```json
{
	"target_repo": "/absolute/path/to/project",
	"test_files": ["absolute paths, read-only"],
	"target_module": "absolute path where impl goes",
	"impl_path_pattern": "e.g. src/main/java/**",
	"test_runner_command": "e.g. ./mvnw test",
	"prior_impl_files": ["existing impl to extend, if any"]
}
```

### Green — output

```json
{
	"impl_files_modified": ["absolute paths"],
	"tests_passing": true,
	"approach_summary": "2-3 sentences"
}
```

### Refactor — input

```json
{
	"target_repo": "/absolute/path/to/project",
	"test_files": ["absolute paths, do not modify"],
	"impl_files": ["absolute paths, modify freely"],
	"test_runner_command": "e.g. ./mvnw test",
	"readability_targets": "optional notes"
}
```

### Refactor — output

```json
{
	"files_changed": ["absolute paths"],
	"loc_delta": -3,
	"tests_still_passing": true,
	"changes_summary": "what got simpler, tradeoffs, escalations"
}
```

## Rules

- **Never skip Red.** If the user says "just implement X", insist on
  tests first or decline the skill. You can offer to drop the skill and
  implement normally — but don't fake a TDD loop without Red.
- **One behavior per loop iteration.** Don't batch multiple behaviors
  into a single Red dispatch.
- **Absolute paths only in dispatches.** Subagents don't share your
  working-directory intuition; they need absolute paths.
- **If Red returns `confirmed_failing: false`, stop and ask.** The test
  passed against current impl, which means it didn't force any new code
  this cycle. That may be a mistake in behavior ordering, or it may be
  a legitimate regression guard (closer to Michael Feathers'
  characterization testing than to Beck's red/green discipline).
  Either way, surface the situation to the user with options:
  1. **Reorder** — tackle a different remaining behavior first, one
     that _will_ fail against current impl, then come back.
  2. **Reformulate** — have Red rewrite the assertion so it forces new
     code (often this means the behavior was phrased too loosely).
  3. **Keep as pin-down** _(default if the user is uncertain)_ — the
     behavior is already covered by existing impl. Keep the test as a
     regression guard and continue to the next behavior. Discarding
     the test entirely is possible but requires the user to explicitly
     say so — do not default to discard.
     Log which path you took in the phase summary.
- **Handle subagent escalations by classifying them, not by always
  asking.** When a subagent (usually Refactor or Green) raises an
  escalation in its output — or when Green's test run surfaces a
  failure in code outside the feature's direct scope — decide what to
  do before acting:

  **First: check the target's routing table.** If the target project's
  `AGENTS.md` has a topic-doc routing table and the escalation or
  failure touches an area it covers (database/schema, dependencies,
  infrastructure, security, frontend, etc.), **fetch the relevant topic
  doc and apply its escalation rules before classifying**. These rules
  override the auto-classification below. Schema migrations, new
  library dependencies, and cross-cutting infrastructure changes always
  stop and ask the user — even when the fix could be captured as a
  test or auto-dispatched as a routine bug. You may not re-dispatch
  Green to make a schema, migration, or dependency change without
  explicit user confirmation.

  Otherwise, classify and act:
  1. **Bug in code the current feature owns, capturable as a single
     failing test.** Don't ask. Insert a new behavior at the front of
     the remaining queue (short description of the bug as the expected
     behavior), log the insertion in your phase summary, and dispatch
     Red for it on the next iteration. The normal loop handles the fix.
  2. **Structural suggestion** — extract to new file, rename across
     the codebase, add a type this feature doesn't own, etc. Note it
     in the final summary. Do not act. Do not ask.
  3. **Scope-ambiguous** — the escalation touches code the current
     feature doesn't clearly own, or the "right answer" isn't a single
     test. _This_ is when you stop and ask the user. Present the
     escalation verbatim and wait.
     When in doubt between (1) and (3), prefer (1). Adding test coverage
     to code the feature touches fails safe.

- **Green retries are yours to count.** If Green returns with
  `tests_passing: false`, re-dispatch Green with the failure output
  appended. Up to 3 re-dispatches before surfacing to the user.
- **If Refactor returns `tests_still_passing: false`,** stop and report
  to the user. Don't attempt to fix it yourself; suggest
  `git checkout -- <impl files>` as a safe revert.
- **Between phases, keep your own context minimal.** You're the only
  thing that sees all three subagents' output. Summarize, don't hoard.
