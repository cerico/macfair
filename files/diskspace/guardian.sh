#!/bin/bash
# Cleans caches when disk space drops below threshold
MIN_FREE_GB=15
FREE_GB=$(df -g / | awk 'NR==2 {print $4}')
LOG=~/.local/share/diskspace.log

[[ $FREE_GB -ge $MIN_FREE_GB ]] && exit 0

mkdir -p ~/.local/share

echo "$(date '+%Y-%m-%d %H:%M'): Low disk (${FREE_GB}GB). Cleaning..." >> "$LOG"

rm -rf ~/.cache/uv ~/Library/Caches/pip 2>/dev/null
npm cache clean --force 2>/dev/null
rm -rf ~/Library/Caches/lima ~/Library/Caches/com.todesktop* 2>/dev/null
podman system prune -af 2>/dev/null
rm -rf ~/Library/Caches/sh.tight.voice-code 2>/dev/null
brew cleanup --prune=all 2>/dev/null
go clean -cache 2>/dev/null
pnpm store prune 2>/dev/null

NEW_FREE=$(df -g / | awk 'NR==2 {print $4}')
echo "$(date '+%Y-%m-%d %H:%M'): Cleaned. Now ${NEW_FREE}GB free." >> "$LOG"
