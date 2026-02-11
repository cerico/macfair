#!/usr/bin/env bun
// SessionStart hook: Inject date/time and location context with state persistence
// Name the file after your assistant (e.g., celeste.ts, claude.ts)

import { basename, join } from 'path'
import { existsSync, readFileSync, writeFileSync } from 'fs'
import { execSync } from 'child_process'
import { homedir } from 'os'

interface LocationState {
  city: string
  date: string
}

interface HubEntry {
  name: string
  path: string
  progress?: string
  status?: string
  last_accessed: number
}

interface HubRegistry {
  hubs: HubEntry[]
}

function getAssistantName(): string {
  // Derive name from filename (celeste.ts → Celeste)
  const filename = basename(process.argv[1], '.ts')
  return filename.charAt(0).toUpperCase() + filename.slice(1)
}

function getTimezone(): string {
  return process.env.TIME_ZONE || Intl.DateTimeFormat().resolvedOptions().timeZone
}

function getTodayDate(tz?: string): string {
  const timezone = tz || process.env.TIME_ZONE || Intl.DateTimeFormat().resolvedOptions().timeZone
  const now = new Date()
  const formatter = new Intl.DateTimeFormat('en-CA', { timeZone: timezone, year: 'numeric', month: '2-digit', day: '2-digit' })
  return formatter.format(now) // YYYY-MM-DD in local timezone
}

function getLocationState(): LocationState | null {
  try {
    const homeDir = process.env.HOME || process.env.USERPROFILE || homedir()
    const stateFile = join(homeDir, '.claude', 'MEMORY', 'State', 'location.json')

    if (!existsSync(stateFile)) {
      return null
    }

    const content = readFileSync(stateFile, 'utf-8')
    const state: LocationState = JSON.parse(content)

    // Check if state is from today
    if (state.date === getTodayDate()) {
      return state
    }

    return null
  } catch (error) {
    return null
  }
}

function getGsdProject(): string | null {
  const cwd = process.cwd()
  const stateFile = join(cwd, '.planning', 'STATE.md')
  const projectFile = join(cwd, '.planning', 'PROJECT.md')

  if (!existsSync(projectFile)) {
    return existsSync(stateFile) ? 'GSD Project' : null
  }

  try {
    const content = readFileSync(projectFile, 'utf-8')
    const match = content.match(/^#\s+(.+)/m)
    if (match) return match[1].trim()
  } catch { /* file read failed, fall through */ }

  return 'GSD Project'
}

function getHubForCurrentDir(): HubEntry | null {
  const homeDir = process.env.HOME || process.env.USERPROFILE || homedir()
  const registryFile = join(homeDir, '.claude', 'hubs', 'registry.json')

  if (!existsSync(registryFile)) {
    return null
  }

  let registry: HubRegistry
  try {
    const content = readFileSync(registryFile, 'utf-8')
    registry = JSON.parse(content)
  } catch {
    return null
  }

  // Validate registry shape before accessing
  if (!registry || !Array.isArray(registry.hubs)) {
    return null
  }

  const cwd = process.cwd()
  const hub = registry.hubs.find(h => h.path === cwd && h.status !== 'archived')

  if (!hub) {
    return null
  }

  // Update last_accessed and sync GSD progress to registry
  hub.last_accessed = Math.floor(Date.now() / 1000)
  if (hub.type === 'gsd') {
    try {
      const stateFile = join(cwd, '.planning', 'STATE.md')
      const state = readFileSync(stateFile, 'utf-8')
      const match = state.match(/^Progress:\s*(.+)/m)
      if (match) hub.progress = match[1].trim()
    } catch {}
  }
  try {
    writeFileSync(registryFile, JSON.stringify(registry, null, 2))
  } catch {
    // Write failed, but still return the hub - don't corrupt state
  }

  return hub
}

function getLocation(tz: string): { location: string; confirmed: boolean } {
  // Check state file first
  const state = getLocationState()
  if (state) {
    return { location: state.city, confirmed: true }
  }

  // Allow manual override via env var
  if (process.env.LOCATION) {
    return { location: process.env.LOCATION, confirmed: true }
  }

  // Parse city from timezone as fallback (e.g., "Europe/Podgorica" → "Podgorica")
  const parts = tz.split('/')
  const fallbackLocation = parts[parts.length - 1].replace(/_/g, ' ')

  return { location: fallbackLocation, confirmed: false }
}

function getLocalDateTime(tz: string): { date: string; time: string; day: string } {
  const now = new Date()

  const dateOpts: Intl.DateTimeFormatOptions = {
    timeZone: tz,
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  }

  const timeOpts: Intl.DateTimeFormatOptions = {
    timeZone: tz,
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }

  const dayOpts: Intl.DateTimeFormatOptions = {
    timeZone: tz,
    weekday: 'long'
  }

  return {
    date: now.toLocaleDateString('en-GB', dateOpts),
    time: now.toLocaleTimeString('en-GB', timeOpts),
    day: now.toLocaleDateString('en-GB', dayOpts)
  }
}

function getHandoff(): { content: string; summary: string } | null {
  const handoffFile = join(process.cwd(), 'tmp', 'handoff.md')

  if (!existsSync(handoffFile)) {
    return null
  }

  try {
    const content = readFileSync(handoffFile, 'utf-8').trim()
    if (!content) return null

    const summaryMatch = content.match(/## Summary\n+(.+)/m)
    const summary = summaryMatch ? summaryMatch[1].trim() : 'context available'

    return { content, summary }
  } catch {
    return null
  }
}

async function main() {
  try {
    const stdinData = await Bun.stdin.text()
    if (!stdinData.trim()) {
      process.exit(0)
    }

    // Skip for subagents
    if (process.env.CLAUDE_CODE_AGENT || process.env.SUBAGENT === 'true') {
      process.exit(0)
    }

    const tz = getTimezone()
    const { location, confirmed } = getLocation(tz)
    const { date, time, day } = getLocalDateTime(tz)
    const name = getAssistantName()

    // Check if current directory is a hub
    const hub = getHubForCurrentDir()
    const hubLine = hub ? `\nHUB: ${hub.name}${hub.progress ? ` (${hub.progress})` : ''}` : ''

    // Check if current directory is a GSD project
    const gsdProject = getGsdProject()
    const gsdBlock = gsdProject ? `\n\nGSD_PROJECT: ${gsdProject}\nGSD_ACTION: Automatically run /gsd:resume-work now to restore context.\nIf in plan mode, exit plan mode first, then run /gsd:resume-work.` : ''

    // Check if on main/master branch
    let branchWarning = ''
    try {
      const branch = execSync('git branch --show-current 2>/dev/null', { encoding: 'utf-8' }).trim()
      const defaultBranch = execSync('git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null', { encoding: 'utf-8' }).trim().replace('refs/remotes/origin/', '')
      if (branch && branch === defaultBranch) {
        branchWarning = `\n\nMAIN_BRANCH_WARNING: You are on the ${branch} branch. Do NOT make code changes or commits here. Ask the user to switch to a feature branch first.`
      }
    } catch { /* not a git repo or no remote */ }

    // Check for previous session handoff
    const handoff = getHandoff()
    const handoffBlock = handoff ? `\n\nPREVIOUS_SESSION:\n${handoff.content}` : ''
    const handoffGreeting = handoff ? ` Previous session: ${handoff.summary}` : ''

    const output = `<system-reminder>
Session Context (Auto-loaded)

DATE: ${date}
TIME: ${time}
DAY: ${day}
LOCATION: ${location}
LOCATION_CONFIRMED: ${confirmed}
TIMEZONE: ${tz}${hubLine}

This context is now active for this session.${gsdBlock}${branchWarning}${handoffBlock}
</system-reminder>

${name} ready. ${day}, ${time} in ${location}.${hub ? ` [${hub.name}${hub.progress ? `: ${hub.progress}` : ''}]` : ''}${handoffGreeting}`

    console.log(output)

  } catch (error) {
    console.error('Context loading error:', error)
  }

  process.exit(0)
}

main()
