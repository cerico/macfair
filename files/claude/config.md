# Claude Configuration

All Claude config lives in `~/macfair/files/claude/`:
- `config.md` → `~/.claude/CLAUDE.md`
- `settings.json` → `~/.claude/settings.json`
- `hooks/`, `commands/`, `skills/` → `~/.claude/`

Never edit `~/.claude/` directly. Edit macfair, then tell user to run `make claude`.

# General

- Prefer idempotent operations - safe to run multiple times with same result
- Prefer proper fixes over quick fixes - investigate root causes rather than masking symptoms
- When presenting multiple options, grade each A-F with score out of 100, weighted towards proper professional solutions
- Be terse, not flowery
- Avoid overusing parentheses in copy
- Check for existing functions/patterns before writing new ones
- Be extremely sparing with comments
- Files must end with a newline
- Empty lines must be completely empty (no whitespace)
- Avoid hyphens in filenames unless strictly necessary (prefer underscores or camelCase)
- Care about errors and accessibility (a11y)
- Use the actual current date from context - don't hallucinate it being a year ago
- Express uncertainty honestly rather than guessing confidently

# Git

- Never commit unless explicitly asked
- Never use co-authored commits
- Never commit sensitive information
- Commits must use semantic versioning prefixes (fix, feat, docs, etc.)
- Branch naming: run git log to check existing pattern
- When amending commits: always use `--reset-author` to update date to now (easier rebasing)
- Multiple commits per branch allowed - squash at merge time if desired
- For commits, use `/commit` workflow
- After commit, run `/review` before pushing

# Shell/Bash

- Prefer `[[ ]] &&` format over `if then fi` blocks

# Ansible

- Use `path_join` filter for paths, not string concatenation

# Package Management

- pnpm
- Don't run `brew install` directly - add to ansible role and let user run `make install`

# Makefile

- Before running commands, check Makefile for existing targets first
- If no Makefile exists, create one
- When running a command that could be reused, add it to the Makefile
- Prefer modular structure: main `Makefile` includes `makefiles/*.mk` files
- Use common sense for placement: project-wide in main Makefile, domain-specific in `.mk` modules
- `makefiles/claude.mk` is metadata only — it declares `VERIFY_TARGETS` (target names safe for Claude to run). Never put recipes in `claude.mk`; actual targets live in the main Makefile or other `.mk` modules
- After making changes, check for `makefiles/claude.mk`. If it exists, read `VERIFY_TARGETS` and run the relevant targets to verify your work

# JavaScript/TypeScript

- No semicolons
- Strict mode, avoid `any`
- Prefer inferred/existing types over manual definitions:
  - `typeof data[number]` for array item types from queries
  - Prisma/Drizzle generated types (`User`, `Upload`)
  - `z.infer<typeof schema>` for Zod schemas
  - tRPC `RouterOutputs['router']['procedure']` for endpoint return types
  - Only define types when no source of truth exists
- Use barrel exports (index files) for clean imports
- Use `@/` path alias instead of relative imports
- Import from specific subdirectories, not root barrel (e.g., `@/components/skeletons` not `@/components`)
- Alias imports when path provides context (e.g., `import { UserSkeleton as Skeleton } from '@/components/skeletons'`)
- Extract inline JSX to small components at top of file when not significant enough for own file
- Zod for validation
- React Hook Form for forms
- Sonner for toast notifications
- Prefer Zustand over Context unless good reason
- i18n for multi-language support
- Store dates in UTC, display in `facilityTimezone` from `NEXT_PUBLIC_FACILITY_TIMEZONE` env
- Date formatting via date-fns-tz in `utils/date.ts`: prefer `formatShortOrdinal`, also `formatShortOrdinalWithYear`, `formatLongOrdinal`, `formatShort`, `formatTime`
- Use `formatInTimeZone` from date-fns-tz, not `format` from date-fns - avoids timezone bugs
- Prefer pagination over infinite scroll
- API tokens in `constants/tokens.ts`: `export const FOO_TOKEN = process.env.NEXT_PUBLIC_FOO_TOKEN`
- Use `Props` not `ComponentNameProps` for local component interfaces
- Pass validated values as props rather than importing potentially undefined constants
- Use context-specific prop names (e.g., `mapboxToken` not `accessToken`)

# React

- Avoid useEffect unless strictly necessary:
  - NOT for derived state (compute directly or use useMemo)
  - NOT for data fetching (use React Query/tRPC/server components)
  - NOT for subscriptions when a hook exists (use `useMediaQuery` not useEffect + matchMedia)
  - YES for syncing with external systems (DOM, third-party libraries)
  - YES for cleanup (event listeners, timers, WebSocket connections)
- When useEffect is needed, always include cleanup function
- Prefer server components for data fetching in Next.js App Router

# CSS/Styling

- Tailwind CSS
- Use theme-aware color tokens (e.g., `text-muted-foreground`, `bg-muted`) not hardcoded colors (`text-gray-500`)
- Class strings: inline if single use, const at top of file if repeated, shared `constants/styles.ts` if across files

# Directory Structure

- hooks/, components/, validations/, constants/, utils/, api/ with barrel exports

# Next.js

- App Router, Server Components by default
- Always use `<Image>` from next/image
- Create loading.tsx and error.tsx for routes
- Prefer skeletons over spinners
- Return flat structures from APIs, only necessary fields
- Use `dynamic(() => import('./component'), { ssr: false })` for browser-only libraries (maps, charts, editors)

# Astro

- Prefer native Astro components over React

# tRPC

- One endpoint per file
- Return flat structures
- Use Zod for return shapes

# Prisma/Drizzle/ORM

- Simple queries inline, complex/reused in services/
- Select only needed fields
- Ask before running migrations

# Testing

- Write tests proactively when adding features
- Never mark a task complete if tests are failing - fix them first
- When writing significant code: run tests via subagent to preserve context, return only failures
- For quick changes: ask user to run tests and report back

# Playwright MCP

When using Playwright MCP for browser automation and testing:
- **Cloudflare/CAPTCHA checks** - Ask user: "There's a human verification check. Can you complete it?"
- **Email verification codes** - Ask user for the code sent to their email, then enter it via MCP
- User handles these two friction points; Playwright handles everything else

# Code Reviews

- Use `/review` skill with level 1-4:
  - `/review 1` - Quick sanity check (blockers only)
  - `/review 2` - Standard review with grade (default)
  - `/review 3` - Deep analysis (loads all check modules)
  - `/review 4` - Reference only (shows what's not covered)
- Always provide a grade A-F and score out of 100

# Recovery & Steering

- Don't silently downgrade implementations — if the task says config-driven, don't hardcode; if it says error handling, don't skip it "for now"
- When the task says "use X", use X — don't substitute Y even if simpler
- If you realise you're building something different from what was asked, stop and say so before continuing
- When stuck or looping on the same error 3+ times, say so explicitly — don't keep retrying the same approach
- When unsure about a requirement, ask — don't assume the easier interpretation
- Don't add "TODO" or "for now" placeholders unless the user explicitly says to defer something
- After completing a multi-step task, verify the result matches the original request, not a drift of it
