---
description: Launch agent tabs in the current zellij session, reading phase config from project-plan.md
argument-hint: "phase <N> | <tab-name>:<command> [<tab-name>:<command> ...]"
disable-model-invocation: true
allowed-tools: Bash(git *) Bash(zellij action *) Bash(cat *) Bash(chmod *) Bash(sleep *) Read Write
---

Open named tabs in the **current** zellij session and start a command in each.

## Arguments

$ARGUMENTS

## Parse arguments

Interpret `$ARGUMENTS` as one of:

**`phase <N>`** (preferred — reads config from project):
1. Derive the repo root: run `git rev-parse --show-toplevel` with the Bash tool.
2. Read `<repo>/project-plan.md` with the Read tool.
3. Locate the "## Agent Launch Configuration" section and its table.
4. Extract every row where the **Batch** column equals `N`.
5. For each row, write a wrapper script to `/tmp/run-<tab-name>.sh`:
   ```bash
   #!/bin/bash
   cd <worktrees-base>/<Worktree>
   export CARGO_TARGET_DIR=<CARGO_TARGET_DIR>
   exec claude --dangerously-skip-permissions "$(cat <repo>/<Prompt>)"
   ```
   Run: `chmod +x /tmp/run-<tab-name>.sh`
   where `<worktrees-base>` is one directory above the repo root, named `<repo-name>-worktrees`
   (e.g. repo at `/home/user/Code/triad` → worktrees at `/home/user/Code/triad-worktrees`).

   Also write the Stop hook into the worktree's `.claude/settings.json`, merging with any
   existing permissions already present. The hook fires when the agent exits and triggers
   `/project-status` in the status tab automatically:
   ```bash
   cat > <worktrees-base>/<Worktree>/.claude/settings.json << 'EOF'
   {
     "permissions": { "allow": ["Bash(cargo fmt *)", "Bash(cargo clippy *)", "Bash(cargo check *)", "Bash(cargo nextest *)", "Bash(cargo build *)", "Bash(cargo install *)", "Bash(cargo llvm-cov *)", "Bash(git -C *)", "Bash(git branch *)", "Bash(git rebase *)", "Bash(git merge *)", "Bash(git worktree *)", "Bash(gh pr *)", "Bash(CARGO_TARGET_DIR=/tmp/*)", "Bash(zellij action *)", "Bash(ls -1d *)"], "deny": [], "ask": [] },
     "hooks": {
       "Stop": [{"matcher": "", "hooks": [{"type": "command", "command": "zellij action go-to-tab-name status; zellij action write-chars $'/project-status\\n'"}]}]
     }
   }
   EOF
   ```
   Skip this step if the worktree directory does not exist yet.
6. After all agent tabs, write a status wrapper script and open the status tab.
   The wrapper runs `/project-status` immediately as the initial prompt so the first
   status check starts without any manual action:
   ```bash
   cat > /tmp/run-status.sh << 'STATUSEOF'
   #!/bin/bash
   cd <repo>
   exec claude --dangerously-skip-permissions "$(cat /home/jreuben1/.dotfiles/claude/.claude/commands/project-status.md)"
   STATUSEOF
   chmod +x /tmp/run-status.sh
   ```
   ```bash
   zellij action new-tab --name "status" -- /tmp/run-status.sh
   ```
   Capture the returned tab ID as `STATUS_TAB_ID`.

6b. Auto-start `/loop` in the status tab. Sleep 10 s to let claude initialise, then
    send `/loop` — it is buffered while project-status runs and fires immediately after
    the first run completes, establishing continuous polling:
   ```bash
   sleep 10
   zellij action go-to-tab-by-id <STATUS_TAB_ID>
   zellij action write-chars $'/loop\n'
   ```
   After sending, navigate back to the first agent tab so the user lands there.

7. After opening all tabs, list which tabs have `/loop? = yes` and tell the user:
   > Switch to the `<tab-name>` tab and run `/loop` to start iterative TDD.

**`<tab-name>:<command>` pairs** (manual, space-separated):
Open each pair as a tab named `<tab-name>` running `<command>`.

**No arguments**: print usage and stop.

## Tab-open procedure

**Atomic single-call launch — no write-chars, no sleep, no race condition.**

For each agent tab, execute ONE Bash call:

```bash
zellij action new-tab --name "<name>" -- /tmp/run-<name>.sh
```

This creates the tab with the command already running. No focus timing needed.

For the final `status` tab, use the wrapper written in step 6:

```bash
zellij action new-tab --name "status" -- /tmp/run-status.sh
```

Run each call with the Bash tool before proceeding to the next tab. Do NOT batch tab-open calls.

## Completion report

```
Opened <N> tab(s): <name1>, <name2>, ...
Status tab: auto-running /project-status, /loop queued — continuous polling active.
[If any /loop tabs]: Run /loop in: <tab-name>, ...
```
