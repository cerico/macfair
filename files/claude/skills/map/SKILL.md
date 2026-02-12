---
name: map
description: Explore codebase and generate project context (mermaid diagram + domain model) in CLAUDE.md
user-invocable: true
---

# Map

Explore the current project codebase and generate a structured context section in CLAUDE.md. This section includes a domain summary, mermaid entity diagram, key concepts glossary, architecture overview, and gotchas.

Uses `<!-- map:start -->` / `<!-- map:end -->` markers for idempotent updates.

## Instructions

### 1. Explore the Codebase

Use a Task agent with `subagent_type=Explore` (thoroughness: "very thorough") to gather project context. The exploration prompt should cover:

**Detect project type** from manifest files:
- `package.json` (Node/JS/TS) - check for Next.js, Express, Remix, Astro, etc.
- `Cargo.toml` (Rust)
- `go.mod` (Go)
- `pyproject.toml` / `requirements.txt` (Python)
- `mix.exs` (Elixir)
- `Gemfile` (Ruby)
- `composer.json` (PHP)

**Read the data model** (if present):
- Prisma schema (`prisma/schema.prisma`)
- SQL migrations (`migrations/`, `drizzle/`, `db/migrate/`)
- TypeORM/Sequelize entities
- GraphQL schema files

**Map routes and endpoints**:
- Next.js `app/` or `pages/` directories
- Express/Fastify route files
- tRPC routers
- API route patterns

**Identify key directories**: Where business logic, components, utilities, services, and config live.

**Understand the domain**: From schema + routes + README + key files, determine what the app does in business terms.

The Explore agent should return a structured summary with all findings. Keep the exploration focused on understanding, not cataloguing every file.

### 2. Generate Content

From the exploration results, write the content that goes between markers. Follow this template:

```markdown
<!-- map:start -->
## Domain

[One paragraph: what this project does, who it's for, and its business domain.]

## Entity Diagram

```mermaid
erDiagram
    [Core entities and their relationships]
    [Limit to ~15-20 relationships max - key entities only]
```

If there's no data model (CLI tools, libraries, config projects), use a flowchart instead:

```mermaid
graph TD
    [Key components/modules and how they connect]
```

## Key Concepts

- **[Entity/Concept]**: [One-line description]
- [5-10 entries covering the domain vocabulary]

## Architecture

[Where things live. Key directories and their roles. Data flow summary.
Reference actual paths like `src/services/` or `app/api/`.]

## Gotchas

- [Non-obvious patterns, edge cases, or decisions future sessions should know]
- [Unusual config, env requirements, or conventions specific to this project]
<!-- map:end -->
```

### 3. Write to CLAUDE.md

Determine the CLAUDE.md path: use the project root (current working directory).

**Three cases:**

**No CLAUDE.md exists:**
Create `CLAUDE.md` with just the markers and generated content.

**CLAUDE.md exists, no markers:**
Read the file. Append two blank lines, then the markers and content at the end.

**Markers already exist:**
Read the file. Use the Edit tool to replace everything from `<!-- map:start -->` through `<!-- map:end -->` (inclusive) with the new markers and content. Content outside markers is never touched.

### 4. Verify

After writing, read back CLAUDE.md and confirm:
- Markers are present and properly paired
- Mermaid diagram syntax is valid (no unclosed blocks)
- Content is between markers
- Nothing outside markers was changed (if file pre-existed)

## Output

Tell the user:
- What project type was detected
- How many entities/routes were found
- Whether CLAUDE.md was created, appended to, or updated
- Suggest re-running `/map` after major schema or architecture changes
