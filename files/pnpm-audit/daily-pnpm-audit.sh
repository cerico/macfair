#!/bin/bash
set -e

# Required env vars
PROJECT_DIR="${AUDIT_PROJECT_DIR:?AUDIT_PROJECT_DIR not set}"
SLACK_WEBHOOK="${AUDIT_SLACK_WEBHOOK:?AUDIT_SLACK_WEBHOOK not set}"

# Ensure PATH includes homebrew and node binaries for cron/launchd environment
NVM_BIN=""
if [[ -d "$HOME/.nvm/versions/node" ]]; then
  NVM_NODE=$(ls "$HOME/.nvm/versions/node" 2>/dev/null | tail -1)
  [[ -n "$NVM_NODE" ]] && NVM_BIN="$HOME/.nvm/versions/node/$NVM_NODE/bin:"
fi
export PATH="/opt/homebrew/bin:/usr/local/bin:${NVM_BIN}$PATH"

LOG_FILE="$PROJECT_DIR/tmp/audit-$(date +%Y%m%d).log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

send_notification() {
  local subject="$1"
  local body="$2"
  log "Sending notification: $subject"
  jq -n --arg subject "*$subject*" --arg body "$body" '{text: "\($subject)\n\($body)"}' | \
    curl -s -X POST -H 'Content-type: application/json' --data @- "$SLACK_WEBHOOK" > /dev/null
}

cd "$PROJECT_DIR"
source .env 2>/dev/null || true
mkdir -p "$PROJECT_DIR/tmp"

log "Starting daily audit"

# Ensure we're on main and up to date
git checkout main 2>/dev/null || true
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  log "ERROR: Could not checkout main (on $CURRENT_BRANCH). Aborting."
  exit 1
fi
git pull origin main || log "Warning: git pull failed, running audit on local copy"
pnpm install --silent 2>/dev/null || true

# Create safety branch
BRANCH_NAME="audit-$(date +%Y%m%d-%H%M%S)"
git checkout -b "$BRANCH_NAME"
log "On safety branch: $BRANCH_NAME"

# Part 1: Check for new vulnerabilities
log "Running pnpm audit..."
set +e
AUDIT_OUTPUT=$(pnpm audit 2>&1)
AUDIT_EXIT=$?
set -e

NEW_VULNS=""
if [[ $AUDIT_EXIT -ne 0 ]]; then
  NEW_VULNS=$(echo "$AUDIT_OUTPUT" | grep -E "│ (Package|Severity|Vulnerable)" | head -20)
  log "New vulnerabilities found"
else
  log "No new vulnerabilities"
fi

# Part 2: Check if existing overrides are still needed
OVERRIDES=$(jq -r '.pnpm.overrides // {} | keys[]' package.json 2>/dev/null)
OVERRIDE_REPORT=""

if [[ -n "$OVERRIDES" ]]; then
  log "Testing if overrides are still needed..."

  # Save original package.json
  cp package.json package.json.backup

  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    log "Testing override: $pkg"

    # Remove this specific override
    jq --arg pkg "$pkg" 'del(.pnpm.overrides[$pkg])' package.json > package.json.tmp
    mv package.json.tmp package.json

    # Clean install and audit
    rm -rf node_modules pnpm-lock.yaml 2>/dev/null || true
    if ! pnpm install --silent 2>/dev/null; then
      log "Install failed for $pkg, marking as still needed"
      OVERRIDE_REPORT="$OVERRIDE_REPORT\n⚠️ $pkg - install failed, skipped"
    elif pnpm audit > /dev/null 2>&1; then
      log "Override '$pkg' is NO LONGER NEEDED"
      OVERRIDE_REPORT="$OVERRIDE_REPORT\n✅ $pkg - can be removed"
    else
      log "Override '$pkg' is still needed"
      OVERRIDE_REPORT="$OVERRIDE_REPORT\n🔒 $pkg - still needed"
    fi

    # Restore for next iteration
    cp package.json.backup package.json
  done <<< "$OVERRIDES"

  # Restore original
  mv package.json.backup package.json
fi

# Return to main
log "Returning to main branch"
if git checkout main 2>/dev/null; then
  git branch -D "$BRANCH_NAME" 2>/dev/null || true
  pnpm install --silent 2>/dev/null || true
else
  log "WARNING: Could not return to main, staying on $BRANCH_NAME"
fi

# Build consolidated message
MESSAGE=""

if [[ -n "$NEW_VULNS" ]]; then
  MESSAGE="*New Vulnerabilities:*\n\`\`\`$NEW_VULNS\`\`\`"
else
  MESSAGE="*New Vulnerabilities:* None"
fi

if [[ -n "$OVERRIDE_REPORT" ]]; then
  MESSAGE="$MESSAGE\n\n*Override Status:*$OVERRIDE_REPORT"
elif [[ -z "$OVERRIDES" ]]; then
  MESSAGE="$MESSAGE\n\n*Overrides:* None configured"
fi

# Send single notification
if [[ -n "$NEW_VULNS" ]] || echo "$OVERRIDE_REPORT" | grep -q "can be removed"; then
  send_notification "🚨 Audit: Action Needed" "$MESSAGE"
else
  send_notification "✅ Audit: All Clear" "$MESSAGE"
fi

log "Daily audit complete"
