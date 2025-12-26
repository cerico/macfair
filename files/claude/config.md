# General

- Be terse, not flowery
- Check for existing functions/patterns before writing new ones
- Be extremely sparing with comments
- Files must end with a newline
- Empty lines must be completely empty (no whitespace)
- Care about errors and accessibility (a11y)

# Git

- Never commit unless explicitly asked
- Never use co-authored commits
- Never commit sensitive information
- Commits must use semantic versioning prefixes (fix, feat, docs, etc.)
- Branch naming: run git log to check existing pattern

# Shell/Bash

- Prefer `[[ ]] &&` format over `if then fi` blocks

# Package Management

- pnpm

# Makefile

- Always use Makefile for commands

# JavaScript/TypeScript

- No semicolons
- Strict mode, avoid `any`
- Use barrel exports (index files) for clean imports
- Use `@/` path alias instead of relative imports
- Zod for validation
- React Hook Form for forms
- Sonner for toast notifications
- Prefer Zustand over Context unless good reason
- i18n for multi-language support
- Store dates in UTC, display in user's timezone
- Prefer pagination over infinite scroll

# CSS/Styling

- Tailwind CSS

# Directory Structure

- hooks/, components/, validations/, constants/, utils/, api/ with barrel exports

# Next.js

- App Router, Server Components by default
- Always use `<Image>` from next/image
- Create loading.tsx and error.tsx for routes
- Prefer skeletons over spinners
- Return flat structures from APIs, only necessary fields

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
