---
description: Delegate a task to a sub-agent with live monitoring in a zellij pane
argument-hint: <task-description>
---

Delegate the following task to a sub-agent: **$ARGUMENTS**

Execute this complete workflow:

## Step 1: Prepare Task Environment

Generate task identifiers:
```bash
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TASK_HASH=$(echo "$ARGUMENTS" | md5sum | cut -c1-8)
RESULT_FILE="$HOME/var/task-${TIMESTAMP}-${TASK_HASH}.md"
mkdir -p "$HOME/var"
```

## Step 2: Launch Monitoring Pane (Smart Positioning)

Determine the correct direction for pane placement:

```bash
# Detect existing columns and choose direction
# - If multiple columns exist: FOCUS rightmost pane, then position DOWN (stacks vertically)
# - If single column: position RIGHT (creates new column)

# Count non-focused panes to detect if we already created a second column
PANE_COUNT=$(ps aux | grep "spawn-agent-pane.sh" | grep -v grep | wc -l)

if [ "$PANE_COUNT" -gt 0 ]; then
    # At least one agent pane exists - focus rightmost, then go down
    # Move focus to the right (to the agent panes column)
    zellij action focus-next-pane
    DIRECTION="down"
else
    # No agent panes yet - create first one to the right
    DIRECTION="right"
fi

# Launch with close-on-exit flag so it auto-closes when script finishes
zellij action new-pane --close-on-exit --direction "$DIRECTION" --name "sub-agent-${TASK_HASH}" -- ~/.claude/commands/scripts/spawn-agent-pane.sh "$ARGUMENTS" "$RESULT_FILE"
```

The pane will:
- Position intelligently (down if rightmost column exists, right if not)
- Stack vertically with other agent panes in same column
- Display task information with visual header
- Show progress updates every 5 seconds
- Monitor for result file creation
- Auto-close 3 seconds after completion
- Stay open for entire task duration (max 5 minutes)
- Close automatically when script exits (--close-on-exit)

## Step 3: Spawn Sub-Agent (Immediately After Pane Launch)

Use Task tool with subagent_type="general-purpose" with this prompt:

```
Task: $ARGUMENTS

Instructions:
1. Execute the task: "$ARGUMENTS"
2. Gather all necessary information using available tools
3. Create a comprehensive markdown report with your findings
4. Write the complete results to: $RESULT_FILE

Format the output file as:
---
task_id: ${TIMESTAMP}-${TASK_HASH}
task: $ARGUMENTS
timestamp: $(date '+%Y-%m-%d %H:%M:%S')
status: completed
---

# Task Results: $ARGUMENTS

## Summary
[Executive summary of findings]

## Detailed Results
[Main content organized in clear sections]

## Conclusions
[Key takeaways and recommendations]

## Metadata
- Completion time: [timestamp]
- Tools used: [list of tools]

CRITICAL: Ensure you write the complete results to $RESULT_FILE before finishing.
The monitoring pane is waiting for this file to contain content.

Return message: "Task '$ARGUMENTS' completed. Results written to: $RESULT_FILE"
```

## Step 4: Notification

After sub-agent completes, notify me:
"✅ Sub-agent task completed: '$ARGUMENTS'

📄 Results available at: $RESULT_FILE
🖥️  Monitoring pane will close after user acknowledges (press any key in pane)"

## Expected Behavior

1. **Pane appears** at top of rightmost column
2. **Shows live status** - updates every 5 seconds while waiting
3. **Stays open** during entire task execution
4. **Shows completion** when result file is created
5. **Waits for user** to press a key before closing
6. **Parent agent notified** with result file path

Execute all steps in sequence now.
