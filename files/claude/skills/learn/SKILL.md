---
name: learn
description: Deep-dive into the current project, produce a comprehensive learning document, then generate an infographic from it.
---

# Learn

Explore the current project thoroughly and produce a learning document summarizing everything important, then generate a visual infographic.

## Instructions

### 1. Explore the Project

Use whatever tools make sense to understand the project. Be thorough but efficient:

- **Identity**: README, package.json, Cargo.toml, pyproject.toml, go.mod, or equivalent. What does this project do?
- **Structure**: Directory layout, key directories, entry points
- **Tech stack**: Languages, frameworks, libraries, databases
- **Architecture**: How code is organized, key abstractions, design patterns
- **Data flow**: How data moves through the system — APIs, state management, database interactions
- **Core logic**: Read key source files to understand the main business logic
- **Development workflow**: Scripts, CI/CD, testing setup, build process
- **Git history**: Recent commits for project evolution and active areas

Adapt to what the project actually is. A Rust CLI needs different exploration than a Next.js app.

### 2. Write Learning Document

Create `tmp/learn.md` (create `tmp/` directory if needed).

Structure the document with these sections (skip any that don't apply):

```markdown
# [Project Name]

## What It Does
One paragraph summary of the project's purpose and domain.

## Tech Stack
Languages, frameworks, key libraries, infrastructure.

## Architecture
How the codebase is organized. Key directories and their roles.
Include a simple ASCII diagram if it helps explain data flow.

## Key Abstractions
The main concepts, models, and patterns. What would a new developer need to understand first?

## Core Logic
How the main features work. Walk through the important code paths.

## Data Flow
How data enters, transforms, persists, and exits the system.

## Development Workflow
How to run, test, build, and deploy.

## Notable Design Decisions
Interesting choices, tradeoffs, or patterns worth noting.

## Areas of Complexity
Parts that are non-obvious or would trip up a newcomer.
```

Write for someone joining the project. Be specific — reference actual files, functions, and patterns. Avoid generic descriptions.

### 3. Generate Infographic

After writing the learning document, invoke `/infographic` with the content of `tmp/learn.md` to produce a visual summary.

## Output

Tell the user:
- Learning document written to `tmp/learn.md`
- Infographic generated via `/infographic`
- Remind them to run `make claude` if this is a new skill installation
