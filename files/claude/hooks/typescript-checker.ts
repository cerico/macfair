#!/usr/bin/env bun
// typescript-checker.ts
// PostToolUse hook: Runs tsc after Edit/Write on .ts/.tsx files
// Feeds errors back to Claude so it can self-correct

interface PostToolUsePayload {
  session_id: string
  tool_name: string
  tool_input: Record<string, any>
}

function findTsConfig(filePath: string): string | null {
  const { dirname, join } = require("path")
  const { existsSync } = require("fs")

  let dir = dirname(filePath)
  const root = "/"

  while (dir !== root) {
    const candidate = join(dir, "tsconfig.json")
    if (existsSync(candidate)) return dir
    dir = dirname(dir)
  }

  return null
}

async function main() {
  try {
    const stdinData = await Bun.stdin.text()
    if (!stdinData.trim()) {
      process.exit(0)
    }

    const payload: PostToolUsePayload = JSON.parse(stdinData)
    const filePath: string = payload.tool_input?.file_path ?? ""

    if (!filePath.match(/\.tsx?$/)) {
      process.exit(0)
    }

    const projectDir = findTsConfig(filePath)
    if (!projectDir) {
      process.exit(0)
    }

    const proc = Bun.spawn(["bun", "x", "tsc", "--noEmit", "--pretty"], {
      cwd: projectDir,
      stdout: "pipe",
      stderr: "pipe",
      env: { ...process.env, FORCE_COLOR: "0" },
    })

    const timeout = setTimeout(() => {
      proc.kill()
    }, 15_000)

    const stdout = await new Response(proc.stdout).text()
    const stderr = await new Response(proc.stderr).text()
    const exitCode = await proc.exited

    clearTimeout(timeout)

    if (exitCode !== 0 && stdout.trim()) {
      const lines = stdout.trim().split("\n")
      const capped = lines.length > 30 ? [...lines.slice(0, 30), `... (${lines.length - 30} more lines)`] : lines
      console.log(`TypeScript errors after editing ${filePath}:\n${capped.join("\n")}`)
    }
  } catch (error) {
    // Never crash — log and exit cleanly
    console.error("typescript-checker error:", error)
  }

  process.exit(0)
}

main()
