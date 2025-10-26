#!/bin/bash
# Spawn Agent Pane - Intelligently position and manage sub-agent execution pane

TASK_DESC="$1"
RESULT_FILE="$2"

# Create a visual header
cat << 'EOF'
╔═══════════════════════════════════════════════════════════╗
║           🤖 SUB-AGENT TASK EXECUTION                     ║
╚═══════════════════════════════════════════════════════════╝
EOF

echo ""
echo "📋 Task: $TASK_DESC"
echo "📝 Result: $RESULT_FILE"
echo "⏰ Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔄 Sub-agent is working..."
echo "   (This pane will remain open until task completes)"
echo ""

# Wait for the result file to be created and have content
WAIT_TIME=0
MAX_WAIT=300  # 5 minutes max

while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
        # File exists and has content
        echo "✅ Task completed!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📄 Results saved to:"
        echo "   $RESULT_FILE"
        echo ""
        echo "⏱️  Duration: ${WAIT_TIME}s"
        echo ""
        echo "🎉 Closing pane in 3 seconds..."
        sleep 3
        exit 0
    fi

    # Show progress indicator
    if [ $((WAIT_TIME % 5)) -eq 0 ] && [ $WAIT_TIME -gt 0 ]; then
        echo "⏳ Still working... (${WAIT_TIME}s elapsed)"
    fi

    sleep 1
    WAIT_TIME=$((WAIT_TIME + 1))
done

echo "⚠️  Timeout reached after ${MAX_WAIT}s"
echo "   Check if sub-agent is still running"
echo ""
echo "Closing pane in 5 seconds..."
sleep 5
