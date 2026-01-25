#!/usr/bin/env bun
// SessionStart hook: Inject date/time and location context with state persistence
// Name the file after your assistant (e.g., celeste.ts, claude.ts)

import { basename, join } from 'path'
import { existsSync, readFileSync, writeFileSync } from 'fs'
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

  // Update last_accessed and write back
  hub.last_accessed = Math.floor(Date.now() / 1000)
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

    const output = `<system-reminder>
Session Context (Auto-loaded)

DATE: ${date}
TIME: ${time}
DAY: ${day}
LOCATION: ${location}
LOCATION_CONFIRMED: ${confirmed}
TIMEZONE: ${tz}${hubLine}

This context is now active for this session.${confirmed ? '' : '\n\nLOCATION NOT CONFIRMED: Ask "Where are you today?" and update ~/.claude/MEMORY/State/location.json with: {"city": "TheirAnswer", "date": "' + getTodayDate() + '"}'}
</system-reminder>

${name} ready. ${day}, ${time} in ${location}.${hub ? ` [${hub.name}${hub.progress ? `: ${hub.progress}` : ''}]` : ''}`

    console.log(output)

  } catch (error) {
    console.error('Context loading error:', error)
  }

  process.exit(0)
}

main()
