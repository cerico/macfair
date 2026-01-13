#!/bin/bash
# PreCompact hook: Save session state and warn to exit
# This hook runs when conversation context is approaching limit

# Create tmp directory if needed
mkdir -p tmp

# Generate filename with timestamp
SUMMARY_FILE="tmp/summary-$(date +%Y-%m-%d-%H%M).md"

# Generate summary with git state
cat > "$SUMMARY_FILE" << EOF
# Session Summary

**Generated:** $(date +"%Y-%m-%d %H:%M:%S")
**Branch:** $(git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "not a git repo")

## Git State

\`\`\`
$(git status 2>/dev/null || echo "Not a git repo")
\`\`\`

## Recent Commits

\`\`\`
$(git log --oneline -5 2>/dev/null || echo "No commits")
\`\`\`

## Uncommitted Changes

\`\`\`
$(DIFF_OUTPUT=$(git diff --stat 2>/dev/null | head -20); echo "${DIFF_OUTPUT:-No changes}")
\`\`\`

## TODO Items

$(if [[ -f TODO.md ]]; then grep "^- \[ \]" TODO.md | head -10 || echo "No unchecked items"; else echo "No TODO.md"; fi)

## Session Notes

[Add 2-3 sentence summary here describing:
- What we were working on
- Key decisions made
- What to do next]

EOF

# Output warning to Claude
cat << 'WARNING'
⚠️  SESSION CHECKPOINT - CONTEXT LIMIT APPROACHING

This conversation is about to compact (summarize old messages).
Best practice: EXIT and start a fresh session to avoid context degradation.

WARNING

echo "I've created: $SUMMARY_FILE"
echo ""
echo "Please add a brief summary to that file describing:"
echo "  - What we were working on"
echo "  - Key decisions made"
echo "  - What to do next"
echo ""
echo "Then EXIT this session (Cmd+Q or 'exit') and start fresh."
echo "Review tmp/summary-*.md files anytime to recall context."
echo ""

# Trigger diary entry for long-term memory
if [[ -f ~/.claude/ruben/hooks/pre-compact-diary.sh ]]; then
  ~/.claude/ruben/hooks/pre-compact-diary.sh
fi
