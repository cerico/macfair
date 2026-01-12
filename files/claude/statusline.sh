#!/bin/bash
# Status line: user | directory | branch | model | tokens

# Read JSON from stdin (passed by Claude Code)
input=$(cat)

# ANSI color codes
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[0;31m'
MAGENTA='\033[1;35m'
DIM='\033[2m'
RESET='\033[0m'

# Basic info
USER=$(whoami)
DIR=$(pwd | sed "s|^${HOME}|~|")
BRANCH=$(git branch --show-current 2>/dev/null)
DIRTY=$(git status --porcelain 2>/dev/null)
DISK_FREE=$(df -h . 2>/dev/null | awk 'NR==2 {print $4}')

# Parse JSON input from Claude Code
if command -v jq &> /dev/null && [ -n "$input" ]; then
    MODEL=$(echo "$input" | jq -r '.model.display_name // empty')

    # Get token data directly from context_window
    TOTAL_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
    CONTEXT_LIMIT=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

    # Calculate percentage and build display
    if [ "$TOTAL_TOKENS" -gt 0 ]; then
        PCT=$(echo "scale=0; $TOTAL_TOKENS * 100 / $CONTEXT_LIMIT" | bc)

        # Cap at 100% for display
        DISPLAY_PCT=$PCT
        [ "$DISPLAY_PCT" -gt 100 ] && DISPLAY_PCT=100

        # Build progress bar (10 chars) using Unicode blocks
        FILLED=$(echo "scale=0; $DISPLAY_PCT / 10" | bc)
        EMPTY=$((10 - FILLED))
        BAR=""
        for ((i=0; i<FILLED; i++)); do BAR+="█"; done
        for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

        # Format token counts
        if [ "$TOTAL_TOKENS" -ge 1000 ]; then
            TOK_DISPLAY=$(echo "scale=1; $TOTAL_TOKENS / 1000" | bc | sed 's/\.0$//')K
        else
            TOK_DISPLAY=$TOTAL_TOKENS
        fi

        LIMIT_DISPLAY=$(echo "scale=0; $CONTEXT_LIMIT / 1000" | bc)K

        TOKEN_DISPLAY="${BAR} | ${PCT}% | ${TOK_DISPLAY} / ${LIMIT_DISPLAY}"
    fi
fi

# Build output - model & tokens first, then user/dir/branch
OUTPUT=""

# Add model
if [ -n "$MODEL" ]; then
    OUTPUT="${MAGENTA}${MODEL}${RESET}"
fi

# Add tokens
if [ -n "$TOKEN_DISPLAY" ]; then
    [ -n "$OUTPUT" ] && OUTPUT="$OUTPUT | "
    OUTPUT="$OUTPUT${DIM}${TOKEN_DISPLAY}${RESET}"
fi

# Add user
[ -n "$OUTPUT" ] && OUTPUT="$OUTPUT | "
OUTPUT="$OUTPUT${CYAN}${USER}${RESET}"

# Add directory
OUTPUT="$OUTPUT | ${GREEN}${DIR}${RESET}"

# Add git branch with status indicator
if [ -n "$BRANCH" ]; then
    if [ -n "$DIRTY" ]; then
        OUTPUT="$OUTPUT | ${RED}${BRANCH} ✗${RESET}"
    else
        OUTPUT="$OUTPUT | ${GREEN}${BRANCH} ✓${RESET}"
    fi
fi

# Add disk free
if [ -n "$DISK_FREE" ]; then
    OUTPUT="$OUTPUT | ${DIM}${DISK_FREE}${RESET}"
fi

echo -e "$OUTPUT"
