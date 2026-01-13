# General

- Prefer idempotent operations - safe to run multiple times with same result
- Do not edit ~/.claude/CLAUDE.md directly - edit ~/macfair/files/claude/config.md instead
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
- One commit per branch - squash before pushing
- For commits, use `/commit` workflow
- After commit, run `/review-pr` before pushing

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

# JavaScript/TypeScript

- No semicolons
- Strict mode, avoid `any`
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

# Code Reviews

- When asked to review code or a PR, provide a grade A-F and score out of 100
