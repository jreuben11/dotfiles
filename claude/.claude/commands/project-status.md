---
description: Show development status for a multi-worktree Cargo project, then merge and close tabs for completed worktrees
argument-hint: ""
allowed-tools: Bash(git *) Bash(cargo check *) Bash(cargo nextest *) Bash(zellij action *) Bash(gh pr *) Bash(gh pr merge *) Bash(sleep *) Read Write
---

Show development status driven by the project plan checklist, then merge and close tabs for completed worktrees.

## Rules for bash calls
**Never use pipes (`|`) in any Bash tool call.** Use native flags (e.g. `git log -n 20`),
the Read tool for file content, or separate sequential Bash calls instead.

## Steps

**1. Derive paths**

```bash
git rev-parse --show-toplevel
```

`REPO` = result. `WORKTREES` = sibling dir `<repo-name>-worktrees`.

**2. Header**

```
════════════════════════════════════════════════════
 <repo-name> — Development Status  <YYYY-MM-DD HH:MM>
════════════════════════════════════════════════════
```

**3. Git branches** (no pipe — use `-n 20` flag):

```bash
git -C <REPO> log --oneline --all --graph --decorate -n 20
```

**4. Worktree list**

```bash
git -C <REPO> worktree list
```

**5. Plan-driven worktree state map**

Use the Read tool to read `<REPO>/project-plan.md`. Parse it in memory:

a. Find the **Agent Launch Configuration** table. Extract all rows: `{batch, tab, worktree-dir, prompt, loop}`.

b. For each worktree-dir, find its corresponding plan section (search for its branch name like
   `feat/triad-core`). Count `[x]` (done) and `[ ]` (todo) items in that section.

c. Classify each worktree:
   - **`merged`**: branch already in `git -C <REPO> branch --merged main` output
   - **`plan-complete`**: all plan items are `[x]` → ready to merge once tests pass
   - **`in-progress`**: at least one `[x]` item → agent has done some work
   - **`not-started`**: all items are `[ ]` → scaffold only, skip testing

d. Print a table:
```
WORKTREE STATE
  <branch padded to 45>  <state>  (<done>/<total> plan items)
```

e. Phase-grouped checklist summary.

Parse all `## Phase N` section headers from the plan. For each phase count its `[x]` and `[ ]` items.
The **current phase** = the lowest-numbered phase that has any `[ ]` items.

Print:
```
PROJECT PLAN  (main branch)
  All items: X done / Y total   Phases complete: P / Q

CURRENT PHASE: Phase N — <title>
  · <remaining item 1>
  · <remaining item 2>
  ... (show ALL remaining items for the current phase, up to 20)

UPCOMING PHASES:
  Phase N+1 — <title>  (M items remaining)
  Phase N+2 — <title>  (K items remaining)
  ...
```

If all phases are complete, print:
```
  ✓ All plan items complete — ready to tag v0.1.0
```

**6. Workspace compile check** (main branch only):

```bash
cargo check --workspace --manifest-path <REPO>/Cargo.toml
```

Exit 0 → `  ✓ workspace compiles`. Non-zero → up to 5 `error` lines prefixed `✗`.

**7. Per-worktree test results** (skip `not-started` and `merged`)

Get the current main SHA (one call):
```bash
git -C <REPO> rev-parse main
```

For each worktree classified as `in-progress` or `plan-complete`:

```bash
git -C <wt-path> rev-list <main-SHA>..HEAD --count
```

If count is 0 (no commits ahead of main), treat as scaffold and skip nextest.
If count > 0, run (two sequential calls — no `cd`, no pipes):

```bash
git -C <wt-path> branch --show-current
```
```bash
cargo nextest run --manifest-path <wt-path>/Cargo.toml
```

Interpret:
- Exit 0 → `PASS  <summary>`
- Exit 4 / "no tests to run" in output → `no tests yet`
- Other non-zero → `FAIL  <first error line>`

Run **sequentially**. Collect `PASS` branches into `PASSING_BRANCHES`.

**8. Footer**

```
════════════════════════════════════════════════════
```

**9. Merge and close completed worktrees**

Only attempt merge if the worktree is **both** `plan-complete` **and** in `PASSING_BRANCHES`.

For each qualifying branch:

a. Already merged? Check output of `git -C <REPO> branch --merged main` in memory.
   If present → skip to (f).

b. Three-file discipline check — verify `claude-best-practices-learned.md` was touched:
   ```bash
   git -C <wt-path> log --name-only --format="" main..HEAD
   ```
   Read the file list in memory. If `claude-best-practices-learned.md` does NOT appear, print:
   ```
   ⚠  <branch>: claude-best-practices-learned.md not committed — agent skipped three-file discipline
   ```
   Continue with the merge anyway (warn, don't block).

c. Check for an open PR on this branch:
   ```bash
   gh pr list --head <branch> --state open --json number,title
   ```
   - **PR found** → merge via GitHub (go to d).
   - **No PR** → merge directly (go to e).

d. PR merge path (squash to keep main history clean — one commit per phase):
   ```bash
   gh pr merge <branch> --squash --delete-branch
   ```
   If the command fails because CI checks are failing, print:
   ```
   ⚠  <branch>: PR checks failing — skipping merge until green
   ```
   and skip to (g). On success → go to (f).

e. Direct merge path (no PR — legacy or manual branches):
   ```bash
   git -C <REPO> merge --ff-only <branch>
   ```
   Success → go to (f).
   If ff fails, rebase then retry:
   ```bash
   git -C <WORKTREES>/<wt-dir> rebase main
   ```
   Success → retry `git -C <REPO> merge --ff-only <branch>`. On conflict:
   ```bash
   git -C <WORKTREES>/<wt-dir> rebase --abort
   ```
   Print warning with conflicting files and skip to (g).

f. Close the agent tab — only if the tab name appears in the Agent Launch Configuration table:

   If the branch's tab name is NOT in the table (e.g. a manually-named tab), print:
   ```
   ⚠  <branch>: tab name not in Agent Launch Configuration — skipping tab close
   ```
   and skip to (g).

   Otherwise, get the tab ID:
   ```bash
   zellij action list-tabs
   ```
   Parse the output in memory to find the numeric ID of the tab named exactly `<tab-name>`.
   If no tab with that name is found in the list, print:
   ```
   ⚠  <branch>: tab <tab-name> not found in zellij — skipping tab close
   ```
   and skip to (g).

   Also capture the ID of the `status` tab from the same list-tabs output.

   Only if both IDs are found: navigate and close:
   ```bash
   zellij action go-to-tab-by-id <agent-tab-id>
   ```
   ```bash
   sleep 0.3
   ```
   ```bash
   zellij action close-tab
   ```
   ```bash
   sleep 0.3
   ```
   ```bash
   zellij action go-to-tab-by-id <status-tab-id>
   ```
   Print: `  ✓ Merged <branch> → main via PR, closed tab <tab-name>`
   (or `via direct merge` if no PR was used)

g. (skip label — do nothing further for this branch)

**10. Auto-launch next unblocked batch**

Only run if at least one successful merge happened in step 9.

Get the current merged-branch list (one call):
```bash
git -C <REPO> branch --merged main
```

Using the Agent Launch Configuration table (already in memory from step 5), group rows by Batch number.
For each batch N in ascending order (1, 2, 3, 4):

- **Prerequisite check**: are ALL branches whose Batch = N-1 present in the merged list?
  - Batch 1 prerequisite: feat/triad-proto AND feat/triad-core merged
  - Batch 2 prerequisite: feat/triad-runner-backends merged
  - Batch 3 prerequisite: feat/triad-runner-patterns-cdc-outbox AND feat/triad-runner-patterns-saga-eos merged
  - Batch 4 prerequisite: feat/triad-runner-engine AND feat/triad-sdk AND feat/triad-cli merged
- **Unmerged check**: is at least one branch in batch N NOT in the merged list?

If both true → batch N is the next to launch. Print:
```
  → Batch N is fully unblocked. Launching in 10 seconds... (Ctrl-C to abort)
```
Then:
```bash
sleep 10
```

For each row in batch N (in table order), first write a wrapper script:
```bash
cat > /tmp/run-<tab-name>.sh << 'EOF'
#!/bin/bash
cd <worktrees-base>/<Worktree>
export CARGO_TARGET_DIR=<CARGO_TARGET_DIR>
exec claude --dangerously-skip-permissions "$(cat <REPO>/<Prompt>)"
EOF
chmod +x /tmp/run-<tab-name>.sh
```

Then open the tab atomically (one Bash call — no write-chars, no sleep, no race condition):
```bash
zellij action new-tab --name "<Tab name>" -- /tmp/run-<tab-name>.sh
```

After opening all tabs for batch N:
- Print: `  → Opened tabs: <tab1>, <tab2>, ...`
- For any row with `/loop? = yes`: print `  → Switch to <tab-name> and run /loop to start iterative TDD`
- Stop (only launch one batch per run).

If no batch is unblocked: print `  → No new batch to launch yet — dependencies still in progress.`

**11. Summary**

One sentence: what merged, what launched, what's still running.
