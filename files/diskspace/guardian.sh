#!/bin/bash
# Cleans caches when disk space drops below threshold
MIN_FREE_GB=15
BALLAST_SIZE_GB=5
BALLAST_RECREATE_GB=10
CRITICAL_GB=2
FREE_GB=$(df -g / | awk 'NR==2 {print $4}')
LOG=~/.local/share/diskspace.log
BALLAST=~/.local/share/diskspace_ballast

mkdir -p ~/.local/share

# Always run: clean ephemeral data regardless of disk pressure
find ~/Library/Application\ Support/ru.starmel.OpenSuperWhisper/recordings -name "*.wav" -mmin +60 -delete 2>/dev/null

# Critical: delete ballast immediately for breathing room
if [[ $FREE_GB -lt $CRITICAL_GB && -f "$BALLAST" ]]; then
    rm -f "$BALLAST"
    echo "$(date '+%Y-%m-%d %H:%M'): CRITICAL (${FREE_GB}GB). Deleted ballast file." >> "$LOG"
    FREE_GB=$(df -g / | awk 'NR==2 {print $4}')
fi

# Ensure ballast exists when space is reasonable
if [[ $FREE_GB -ge $BALLAST_RECREATE_GB && ! -f "$BALLAST" ]]; then
    if mkfile ${BALLAST_SIZE_GB}g "$BALLAST" 2>/dev/null; then
        echo "$(date '+%Y-%m-%d %H:%M'): Created ${BALLAST_SIZE_GB}GB ballast file." >> "$LOG"
        FREE_GB=$(df -g / | awk 'NR==2 {print $4}')
    else
        echo "$(date '+%Y-%m-%d %H:%M'): Failed to create ballast file." >> "$LOG"
    fi
fi

[[ $FREE_GB -ge $MIN_FREE_GB ]] && exit 0

echo "$(date '+%Y-%m-%d %H:%M'): Low disk (${FREE_GB}GB). Cleaning..." >> "$LOG"

# Package managers
rm -rf ~/.cache/uv ~/Library/Caches/pip 2>/dev/null
npm cache clean --force 2>/dev/null
pnpm store prune 2>/dev/null
brew cleanup --prune=all 2>/dev/null
go clean -cache 2>/dev/null

# Containers
rm -rf ~/Library/Caches/lima 2>/dev/null
podman system prune -af 2>/dev/null

# Large cache targets
rm -rf ~/.cache/puppeteer 2>/dev/null
rm -rf ~/.cache/huggingface 2>/dev/null
rm -rf ~/.cache/prisma 2>/dev/null

# Browser caches
rm -rf ~/Library/Caches/Vivaldi 2>/dev/null
rm -rf ~/Library/Caches/Arc 2>/dev/null
rm -rf ~/Library/Caches/com.kagi.kagimacOS 2>/dev/null
rm -rf ~/Library/Caches/org.mozilla.firefox 2>/dev/null

# App caches
rm -rf ~/Library/Caches/com.todesktop* 2>/dev/null
rm -rf ~/Library/Caches/sh.tight.voice-code 2>/dev/null
rm -rf ~/Library/Caches/node-gyp 2>/dev/null
rm -rf ~/Library/Caches/@lineardesktop-updater 2>/dev/null
rm -rf ~/Library/Caches/com.steipete.repobar 2>/dev/null

# Unused apps
rm -rf ~/Library/Application\ Support/Wispr\ Flow 2>/dev/null
rm -rf ~/Library/Caches/com.wispr.flow 2>/dev/null

# Time Machine local snapshots
tmutil thinlocalsnapshots / 10000000000 4 2>/dev/null

NEW_FREE=$(df -g / | awk 'NR==2 {print $4}')
echo "$(date '+%Y-%m-%d %H:%M'): Cleaned. Now ${NEW_FREE}GB free." >> "$LOG"
