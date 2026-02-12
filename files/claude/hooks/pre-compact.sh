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

EOF

# Output instructions to Claude
cat << 'INSTRUCTIONS'
⚠️  SESSION CHECKPOINT - CONTEXT LIMIT APPROACHING

Before exiting, you MUST:

1. Write tmp/handoff.md with this structure:

   # Handoff
   **Date**: [today's date]
   **Branch**: [current git branch]
   ## Summary
   [1-2 sentences: what we worked on]
   ## Decisions
   - [key decisions made this session]
   ## Next
   - [what to do next session]
   ## Blockers
   - [any blockers, or "none"]

2. If in a hub directory, run: /hub next <next-action>
3. Tell the user: "Handoff saved. Exit and start a fresh session."

IMPORTANT: Fill in the handoff from conversation context. Do NOT ask the user to fill it in.
INSTRUCTIONS

# Trigger diary entry for long-term memory
if [[ -f ~/.claude/ruben/hooks/pre-compact-diary.sh ]]; then
  ~/.claude/ruben/hooks/pre-compact-diary.sh
fi
