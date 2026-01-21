#!/bin/bash
# Auto-generate diary entry before Claude Code compacts conversation
# This hook runs automatically before compact operations

# Check if ruben is set up
if [[ ! -d ~/.claude/ruben/memory/diary ]]; then
  echo "📝 Diary system not set up (run 'make ruben')."
  exit 0
fi

DIARY_CMD=~/.claude/commands/diary.md
[[ ! -f "$DIARY_CMD" ]] && echo "Diary command not found: $DIARY_CMD" && exit 0

echo ""
echo "Creating diary entry..."
echo ""
cat "$DIARY_CMD"
