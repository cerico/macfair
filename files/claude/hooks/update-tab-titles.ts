#!/usr/bin/env bun
// update-tab-titles.ts
// UserPromptSubmit hook: Update terminal tab title with task context

import { statSync, readFileSync, writeFileSync } from 'node:fs'

const ASSISTANT_NAME = process.env.CLAUDE_NAME || 'Claude'
const TAB_CACHE = '/tmp/iterm-tab-count'
const CACHE_TTL_MS = 30_000

interface UserPromptPayload {
  session_id: string
  prompt?: string
  message?: string
  [key: string]: any
}

function isSingleTab(): boolean {
  try {
    const stat = statSync(TAB_CACHE)
    if (Date.now() - stat.mtimeMs < CACHE_TTL_MS) {
      return readFileSync(TAB_CACHE, 'utf-8').trim() === '1'
    }
  } catch {}

  try {
    const result = Bun.spawnSync({
      cmd: ['osascript', '-e', 'tell application "iTerm2" to count tabs of current window'],
      timeout: 500,
    })
    const single = parseInt(result.stdout.toString().trim(), 10) <= 1
    writeFileSync(TAB_CACHE, single ? '1' : '0')
    return single
  } catch {
    return false
  }
}

function setTitle(title: string): void {
  process.stderr.write(`\x1b]1;${title}\x07`)
  if (isSingleTab()) {
    process.stderr.write(`\x1b]2;${title}\x07`)
  }
}

function extractTaskKeywords(prompt: string): string {
  // Remove common filler words
  const stopWords = new Set([
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'is', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'must', 'can', 'this', 'that',
    'these', 'those', 'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me',
    'my', 'your', 'please', 'help', 'want', 'need', 'like', 'just'
  ])

  // Clean and tokenize
  const words = prompt
    .toLowerCase()
    .replace(/[^\w\s-]/g, ' ')
    .split(/\s+/)
    .filter(word => word.length > 2 && !stopWords.has(word))

  // Take first 3-4 significant words
  const keywords = words.slice(0, 4)

  if (keywords.length === 0) {
    return 'Working'
  }

  // Capitalize first word
  keywords[0] = keywords[0].charAt(0).toUpperCase() + keywords[0].slice(1)

  return keywords.join(' ')
}

async function main() {
  try {
    const stdinData = await Bun.stdin.text()
    if (!stdinData.trim()) {
      process.exit(0)
    }

    const payload: UserPromptPayload = JSON.parse(stdinData)
    const prompt = payload.prompt || payload.message || ''

    if (!prompt || prompt.length < 3) {
      process.exit(0)
    }

    // Generate quick title from keywords
    const keywords = extractTaskKeywords(prompt)
    setTitle(`${ASSISTANT_NAME}: ${keywords}`)

  } catch (error) {
    // Never crash
    console.error('Tab title update error:', error)
  }

  process.exit(0)
}

main()
