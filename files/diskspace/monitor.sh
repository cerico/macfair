#!/bin/bash
# Logs disk usage hourly for trend analysis
LOG=~/.local/share/diskspace_usage.log
mkdir -p ~/.local/share

FREE=$(df -h / | awk 'NR==2 {print $4}')
CACHES=$(du -sh ~/Library/Caches ~/.cache 2>/dev/null | awk '{print $1}' | paste -sd' ')
echo "$(date '+%Y-%m-%d %H:%M') free:$FREE caches:$CACHES" >> "$LOG"
