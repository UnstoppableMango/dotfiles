---
name: moer
description: Mixture-of-Experts code review with verification. Use when reviewing PRs or diffs with the MoE ensemble and human-in-the-loop vetting.
---

# MoE Review (with Verification)

You are running a Mixture-of-Experts code review with a critical verification step. The MoE finds candidates; YOU verify them; the HUMAN decides.

## Principles

1. **The MoE is a search tool, not an authority.** It surfaces possible issues. You verify each one.
2. **Never blindly implement MoE suggestions.** Present findings to the user with your own assessment.
3. **Working code is the baseline.** If it works today, a "fix" that adds complexity or breaks platforms is a regression, not an improvement.
4. **No prior-round context.** Each MoE invocation is a clean slate. Do not tell reviewers what was found before.

## Inputs

Determine what to review from the user's message:

- A PR number → `gh pr diff <number>`
- A branch → `git diff main...<branch>`
- Staged changes → `git diff --cached`
- If unclear, ask.

## Step 1: Dispatch the Specialist MoE

Invoke the `review-specialist-supervisor` agent with a **minimal, clean prompt**:

```
task(
  agent_type: "review-specialist-supervisor",
  mode: "background",
  prompt: "Review the code changes in PR #<N> on repo <owner/repo>.

To get the diff, run:
\`\`\`bash
gh pr diff <N> --repo <owner/repo>
\`\`\`

Dispatch all 6 specialist reviewers (2 passes each) and aggregate their claims."
)
```

**Rules for the prompt:**

- Include ONLY: what to review and where to find it
- Do NOT include: prior findings, fix history, "things to focus on", severity guidance
- Do NOT tell reviewers what platform it runs on or what's "theoretical"
- Let them review blind — that's the point

The supervisor dispatches 7 specialist reviewers (2 passes each, 14 total) in parallel:

- **Correctness** — logic errors, data flow, edge cases, API contracts
- **Security** — auth boundaries, credential lifecycle, injection, access control
- **Concurrency** — lock ordering, TOCTOU, cache coherence, race conditions
- **Test Quality** — do tests verify real behavior or just exercise mocks?
- **Resilience** — partial failure, timeout propagation, inconsistent state, migration safety
- **Performance** — wasteful connections, unnecessary I/O, lock scope, inefficient patterns
- **Policy** — violations of documented team rules in `.github/instructions/`

## Step 2: Verify Each Claim

When the supervisor returns the aggregated claims list, **do not present them directly to the user.** First, verify each one:

For EACH claim:

1. **Check the quote exists.** Does the exact code the reviewer quoted appear in the current diff? If no → hallucinated, drop it.
2. **Check the source file.** Is the file **functional** (drives behavior) or **reference material** (documents history)? Code blocks inside reference material are illustrative → drop it.
3. **Check it's a real bug OR a real rule violation.** Would this cause incorrect behavior in actual usage? OR does it violate an explicit rule in `.github/instructions/`? A rule violation is valid even if the code "works" — compliance is not optional.
4. **Check the fix wouldn't break things.** If the suggested fix introduces platform incompatibility, complexity, or touches working code unnecessarily → note that.
5. **For policy claims: verify the rule exists.** Read the cited instruction file and confirm the exact rule text exists and applies to this file type. If the policy specialist cited a rule that doesn't exist or doesn't apply → drop it.

## Step 3: Present Results

Show the user a table with columns: `#`, `Claim`, `Finding`, `Notes`, `Risk`

```markdown
## MoE Review: [identifier]

| #   | Claim                                    | Finding                                                    | Notes                         | Risk                       |
| --- | ---------------------------------------- | ---------------------------------------------------------- | ----------------------------- | -------------------------- |
| 1   | [specialist's claim — short description] | [your verification result — confirmed/disproven/plausible] | [why — cite what you checked] | [CRITICAL/HIGH/MEDIUM/LOW] |
| 2   | ...                                      | ...                                                        | ...                           | ...                        |

### Recommendations

[Only list confirmed findings that you recommend fixing, with brief rationale]

### Dismissed

[Claims you disproved, with one-line reason each]
```

## Step 4: Wait for Human Decision

**STOP.** Do not fix anything. Present the table and wait for the user to tell you what to act on.

The user may:

- Agree with your findings → you fix the confirmed items
- Override a finding → you adjust
- Ask for another round → go back to Step 1

## Anti-Patterns (DO NOT)

- ❌ Run MoE → immediately implement all findings
- ❌ Include "previous rounds found X" in the reviewer prompt
- ❌ Scope the reviewer prompt to filter findings (that's YOUR job in Step 2)
- ❌ Say "the MoE says X so we should do X" — the MoE doesn't decide
- ❌ Present raw MoE output without verification
- ❌ Fix things that aren't broken to satisfy theoretical concerns
