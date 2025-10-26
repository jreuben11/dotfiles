---
description: Search arXiv for survey papers on a topic and summarize results
argument-hint: <research-topic>
---

Delegate an arXiv survey paper search to a sub-agent:

**Research Topic**: $ARGUMENTS

## Task Execution Plan

1. **Prepare environment**:
   ```bash
   TIMESTAMP=$(date +%Y%m%d-%H%M%S)
   TASK_HASH=$(echo "$ARGUMENTS" | md5sum | cut -c1-8)
   RESULT_FILE="$HOME/var/arxiv-survey-${TIMESTAMP}-${TASK_HASH}.md"
   mkdir -p "$HOME/var"
   ```

2. **Launch persistent monitoring pane** (top-right position):
   ```bash
   zellij action new-pane --direction right --name "arxiv-${TASK_HASH}" -- ~/.claude/commands/scripts/spawn-agent-pane.sh "arXiv survey: $ARGUMENTS" "$RESULT_FILE"
   ```

   This pane will:
   - Stay open during the entire research process
   - Show progress updates every 5 seconds
   - Display completion when results are ready
   - Wait for user acknowledgment before closing

3. **Spawn research sub-agent** using Task tool with this prompt:
   ```
   Research Task: Search arXiv for survey papers related to "$ARGUMENTS"

   Instructions:
   1. Use WebSearch to find recent survey papers on arXiv about: $ARGUMENTS
   2. Look for papers with "survey", "review", or "comprehensive" in the title
   3. Focus on papers from 2024-2025
   4. Identify the top 5 most relevant survey papers
   5. For each paper, extract:
      - Title
      - Authors
      - Publication date
      - arXiv ID
      - Abstract summary (2-3 sentences)
      - Key contributions

   6. Write results to: $RESULT_FILE

   Format the output as a well-structured markdown document with:
   - Executive summary
   - Top 5 papers with details
   - Common themes across surveys
   - Recommended reading order
   - Links to papers

   Return message: "Research completed. Results saved to: $RESULT_FILE"
   ```

4. **Report completion**:
   After sub-agent finishes, notify me:
   "✅ arXiv survey search completed for '$ARGUMENTS'. Results available at: $RESULT_FILE"

Execute this workflow now.
