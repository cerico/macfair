#!/bin/bash
set -euo pipefail
# Status line: user | directory | branch | model | tokens

# Read JSON from stdin (passed by Claude Code)
input=$(cat)

# ANSI color codes
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
ORANGE='\033[38;5;208m'
RED='\033[0;31m'
MAGENTA='\033[1;35m'
DIM='\033[2m'
RESET='\033[0m'

# Basic info
USER=$(whoami)
DIR=$(pwd | sed "s|^${HOME}|~|")
BRANCH=$(git branch --show-current 2>/dev/null || true)
DIRTY=$(git status --porcelain 2>/dev/null || true)

# Branch extras: commit count and last-commit age (feature branches only)
if [[ -n "$BRANCH" ]]; then
    DEFAULT_BRANCH=$({ git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || true; } | sed 's|refs/remotes/origin/||')
    [[ -z "$DEFAULT_BRANCH" ]] && DEFAULT_BRANCH="main"

    if [[ "$BRANCH" != "$DEFAULT_BRANCH" ]]; then
        COMMITS_AHEAD=$(git rev-list --count "${DEFAULT_BRANCH}..HEAD" 2>/dev/null || echo 0)
        [[ "$COMMITS_AHEAD" -gt 0 || -n "$DIRTY" ]] && SHOW_BRANCH_EXTRAS=true

        if [[ "${SHOW_BRANCH_EXTRAS:-}" == "true" ]]; then
            LAST_COMMIT_TS=$(git log -1 --format=%ct 2>/dev/null || true)
            if [[ -n "$LAST_COMMIT_TS" ]]; then
                NOW=$(date +%s)
                AGE_SECS=$((NOW - LAST_COMMIT_TS))
                if [[ $AGE_SECS -lt 60 ]]; then
                    AGE_DISPLAY="now"
                elif [[ $AGE_SECS -lt 3600 ]]; then
                    AGE_DISPLAY="$((AGE_SECS / 60))m ago"
                elif [[ $AGE_SECS -lt 86400 ]]; then
                    AGE_DISPLAY="$((AGE_SECS / 3600))h ago"
                else
                    AGE_DISPLAY="$((AGE_SECS / 86400))d ago"
                fi
            fi
        fi
    fi
fi

DISK_FREE=$(df -h . 2>/dev/null | awk 'NR==2 {print $4}')

# Claude process info
CLAUDE_PID=$PPID

# Memory pressure and load (direct, ~4ms total)
MEM_FREE_PCT=$(memory_pressure 2>&1 | sed -n 's/.*free percentage: \([0-9]*\)%.*/\1/p')
LOAD_AVG=$(sysctl -n vm.loadavg | awk '{print $2}')

# Parse JSON input from Claude Code
if command -v jq &> /dev/null && [[ -n "$input" ]]; then
    MODEL=$(echo "$input" | jq -r '.model.display_name // empty')
    CONTEXT_LIMIT=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

    # Get current context usage from Claude Code 2.0.70+ (not cumulative totals)
    INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
    CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

    TOTAL_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))

    # Effective compaction limit (~155K based on experimental observation)
    # Claude auto-compacts at ~155K, not the theoretical 200K context window
    COMPACTION_LIMIT=155000

    # Validate CONTEXT_LIMIT is a positive integer before division
    if [[ "$CONTEXT_LIMIT" =~ ^[0-9]+$ ]] && [[ "$CONTEXT_LIMIT" -gt 0 ]]; then
        # Calculate percentage against effective compaction limit
        PCT=$((TOTAL_TOKENS * 100 / COMPACTION_LIMIT))

        # Cap display at 100%
        DISPLAY_PCT=$PCT
        [[ $DISPLAY_PCT -gt 100 ]] && DISPLAY_PCT=100

        # Build progress bar (10 chars)
        FILLED=$((DISPLAY_PCT / 10))
        EMPTY=$((10 - FILLED))
        BAR=""
        for ((i=0; i<FILLED; i++)); do BAR+="█"; done
        for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

        # Color based on absolute token thresholds (scaled to 155K compaction limit)
        # Green: <40%, Yellow: <60%, Orange: <90%, Red: >=90% (compaction imminent)
        if [[ "$TOTAL_TOKENS" -le 60000 ]]; then
            BAR_COLOR="$GREEN"
        elif [[ "$TOTAL_TOKENS" -le 95000 ]]; then
            BAR_COLOR="$YELLOW"
        elif [[ "$TOTAL_TOKENS" -le 140000 ]]; then
            BAR_COLOR="$ORANGE"
        else
            BAR_COLOR="$RED"
            COMPACTION_IMMINENT=true
        fi

        # Format token count
        if [[ "$TOTAL_TOKENS" -ge 1000 ]]; then
            TOK_DISPLAY=$(printf "%.0f" "$((TOTAL_TOKENS / 1000))")K
        else
            TOK_DISPLAY=$TOTAL_TOKENS
        fi

        LIMIT_DISPLAY=$((COMPACTION_LIMIT / 1000))K

        TOKEN_DISPLAY="${BAR_COLOR}${BAR}${RESET} ${BAR_COLOR}${PCT}%${RESET} ${DIM}${TOK_DISPLAY}/${LIMIT_DISPLAY}${RESET}"
    fi
fi

# Override all colors to red when compaction is imminent
if [[ "${COMPACTION_IMMINENT:-}" == "true" ]]; then
    CYAN="$RED"
    GREEN="$RED"
    MAGENTA="$RED"
    DIM="$RED"
fi

# Build output - model & tokens first, then user/dir/branch
OUTPUT=""

# Add model
if [[ -n "${MODEL:-}" ]]; then
    OUTPUT="${MAGENTA}${MODEL}${RESET}"
fi

# Add PID
if [[ -n "${CLAUDE_PID:-}" ]]; then
    [[ -n "$OUTPUT" ]] && OUTPUT="$OUTPUT | "
    OUTPUT="$OUTPUT${DIM}${CLAUDE_PID}${RESET}"
fi

# Add tokens
if [[ -n "${TOKEN_DISPLAY:-}" ]]; then
    [[ -n "$OUTPUT" ]] && OUTPUT="$OUTPUT | "
    OUTPUT="$OUTPUT${DIM}${TOKEN_DISPLAY}${RESET}"
fi

# Add user
[[ -n "$OUTPUT" ]] && OUTPUT="$OUTPUT | "
OUTPUT="$OUTPUT${CYAN}${USER}${RESET}"

# Add directory
OUTPUT="$OUTPUT | ${GREEN}${DIR}${RESET}"

# Add git branch with status indicator
if [[ -n "${BRANCH:-}" ]]; then
    if [[ -n "${DIRTY:-}" ]]; then
        BRANCH_DISPLAY="${RED}${BRANCH} ✗${RESET}"
    else
        BRANCH_DISPLAY="${GREEN}${BRANCH} ✓${RESET}"
    fi
    if [[ "${SHOW_BRANCH_EXTRAS:-}" == "true" ]]; then
        BRANCH_DISPLAY="$BRANCH_DISPLAY ${DIM}${COMMITS_AHEAD}↑${RESET}"
        [[ -n "${AGE_DISPLAY:-}" ]] && BRANCH_DISPLAY="$BRANCH_DISPLAY ${DIM}${AGE_DISPLAY}${RESET}"
    fi
    OUTPUT="$OUTPUT | $BRANCH_DISPLAY"
fi

# Add disk free
if [[ -n "${DISK_FREE:-}" ]]; then
    OUTPUT="$OUTPUT | ${DIM}${DISK_FREE}${RESET}"
fi

# Add memory pressure (green >=50%, yellow 30-50%, red <30%)
if [[ -n "${MEM_FREE_PCT:-}" && "$MEM_FREE_PCT" =~ ^[0-9]+$ ]]; then
    if [[ "$MEM_FREE_PCT" -lt 30 ]]; then
        OUTPUT="$OUTPUT | ${RED}${MEM_FREE_PCT}%${RESET}"
    elif [[ "$MEM_FREE_PCT" -lt 50 ]]; then
        OUTPUT="$OUTPUT | ${YELLOW}${MEM_FREE_PCT}%${RESET}"
    else
        OUTPUT="$OUTPUT | ${DIM}${MEM_FREE_PCT}%${RESET}"
    fi
fi

# Add load average if high (>=10)
if [[ -n "${LOAD_AVG:-}" ]]; then
    LOAD_INT=${LOAD_AVG%.*}
    if [[ "$LOAD_INT" =~ ^[0-9]+$ && "$LOAD_INT" -ge 10 ]]; then
        OUTPUT="$OUTPUT | ${RED}LOAD AVERAGE ${LOAD_AVG}${RESET}"
    fi
fi

echo -e "$OUTPUT"
