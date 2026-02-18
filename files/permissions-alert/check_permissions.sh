#!/bin/bash
set -e

SLACK_WEBHOOK="${AUDIT_SLACK_WEBHOOK:?AUDIT_SLACK_WEBHOOK not set}"
PERMISSIONS_FILE="$HOME/.claude/permissions.md"

[[ ! -f "$PERMISSIONS_FILE" ]] && exit 0

# Extract undecided entries (lines starting with - after ## Undecided heading)
UNDECIDED=$(awk '/^## Undecided/{found=1; next} /^## /{found=0} found && /^- /{print}' "$PERMISSIONS_FILE")

[[ -z "$UNDECIDED" ]] && exit 0

COUNT=$(echo "$UNDECIDED" | wc -l | tr -d ' ')
BODY=$(echo "$UNDECIDED" | head -10)
[[ $COUNT -gt 10 ]] && BODY=$(printf '%s\n...and %d more' "$BODY" "$((COUNT - 10))")

BODY=$(printf '%s\n\nRun `/permissions` in any Claude session to triage.' "$BODY")

jq -n \
  --arg subject ":mag: $COUNT undecided tool permission(s) to review" \
  --arg body "$BODY" \
  '{text: "\($subject)\n\($body)"}' | \
  curl -s -X POST -H 'Content-type: application/json' --data @- "$SLACK_WEBHOOK" > /dev/null
