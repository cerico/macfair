#!/usr/bin/env bun
// SessionStart hook: Daily check for package updates
// Runs once per day, notifies about new versions of watched packages

import { dirname, join } from 'path'
import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'fs'
import { homedir } from 'os'

const WATCHED_PACKAGES = ['next', 'react', 'prisma']

interface PackageInfo {
  version: string
  released: string
}

interface State {
  lastChecked: string
  notified: Record<string, PackageInfo>
}

function getTodayDate(): string {
  const tz = process.env.TIME_ZONE || Intl.DateTimeFormat().resolvedOptions().timeZone
  const formatter = new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' })
  return formatter.format(new Date())
}

function getStateFile(): string {
  const homeDir = process.env.HOME || process.env.USERPROFILE || homedir()
  return join(homeDir, '.claude', 'MEMORY', 'State', 'doctor.json')
}

function loadState(): State {
  try {
    const stateFile = getStateFile()
    if (existsSync(stateFile)) {
      return JSON.parse(readFileSync(stateFile, 'utf-8'))
    }
  } catch {}
  return { lastChecked: '', notified: {} }
}

function saveState(state: State): void {
  try {
    const stateFile = getStateFile()
    const dir = dirname(stateFile)
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true })
    writeFileSync(stateFile, JSON.stringify(state, null, 2) + '\n')
  } catch {}
}

function formatShortOrdinalWithYear(date: Date): string {
  const day = date.getUTCDate()
  const suffix = [11, 12, 13].includes(day % 100) ? 'th'
    : day % 10 === 1 ? 'st'
    : day % 10 === 2 ? 'nd'
    : day % 10 === 3 ? 'rd' : 'th'
  const month = date.toLocaleString('en-GB', { month: 'short', timeZone: 'UTC' })
  const year = date.getUTCFullYear()
  return `${day}${suffix} ${month} ${year}`
}

async function getLatestVersion(pkg: string): Promise<PackageInfo | null> {
  try {
    const proc = Bun.spawn(['npm', 'view', pkg, 'version', 'time', '--json'], {
      stdout: 'pipe',
      stderr: 'pipe',
    })
    const output = await new Response(proc.stdout).text()
    const exitCode = await proc.exited
    if (exitCode !== 0) return null
    const data = JSON.parse(output)
    const version = data.version
    const releaseDate = data.time?.[version]
    if (!version || !releaseDate) return null
    const released = formatShortOrdinalWithYear(new Date(releaseDate))
    return { version, released }
  } catch {
    return null
  }
}

async function main() {
  if (process.env.CLAUDE_CODE_AGENT || process.env.SUBAGENT === 'true') {
    process.exit(0)
  }

  const today = getTodayDate()
  const state = loadState()

  if (state.lastChecked === today) {
    process.exit(0)
  }

  const results = await Promise.all(
    WATCHED_PACKAGES.map(pkg => getLatestVersion(pkg).then(info => ({ pkg, info })))
  )

  const updates: string[] = []
  for (const { pkg, info } of results) {
    if (!info) continue
    const lastNotified = state.notified[pkg]
    if (info.version !== lastNotified?.version) {
      updates.push(`${pkg} ${info.version} ${info.released}`)
      state.notified[pkg] = info
    }
  }

  state.lastChecked = today
  saveState(state)

  if (updates.length > 0) {
    console.log(`Doctor: ${updates.join(', ')}`)
  }

  process.exit(0)
}

main()
