#!/bin/bash
set -e

SLACK_WEBHOOK="${AUDIT_SLACK_WEBHOOK:?AUDIT_SLACK_WEBHOOK not set}"
STATE_FILE="$HOME/.local/share/version_alert_state.json"

mkdir -p "$(dirname "$STATE_FILE")"
[[ -f "$STATE_FILE" ]] || echo '{}' > "$STATE_FILE"

PACKAGES=("next" "react")
ALERTS=""

for pkg in "${PACKAGES[@]}"; do
    LATEST=$(curl -sf --connect-timeout 5 --max-time 10 "https://registry.npmjs.org/$pkg/latest" | jq -r '.version // empty')
    [[ -z "$LATEST" ]] && continue

    PREVIOUS=$(jq -r --arg pkg "$pkg" '.[$pkg] // ""' "$STATE_FILE")

    if [[ -n "$PREVIOUS" && "$LATEST" != "$PREVIOUS" ]]; then
        PREV_MINOR="${PREVIOUS%.*}"
        NEW_MINOR="${LATEST%.*}"
        [[ "$PREV_MINOR" != "$NEW_MINOR" ]] && ALERTS+=$'\n:package: '"*$pkg* $PREVIOUS → $LATEST (minor+)"
    fi

    jq --arg pkg "$pkg" --arg ver "$LATEST" '.[$pkg] = $ver' "$STATE_FILE" > "${STATE_FILE}.tmp" \
        && mv "${STATE_FILE}.tmp" "$STATE_FILE"
done

[[ -z "$ALERTS" ]] && exit 0

jq -n \
    --arg subject ":rocket: Package version updates" \
    --arg body "$ALERTS" \
    '{text: "\($subject)\n\($body)"}' | \
    curl -sf --connect-timeout 5 --max-time 10 -X POST -H 'Content-type: application/json' --data @- "$SLACK_WEBHOOK" > /dev/null
