---
name: skills
description: List available skills and what they do. Use when you forget what skills exist or need help choosing the right one.
---

# Skills

Quick reference for available skills.

## Building

| Skill | When to use | Example prompt |
|-------|-------------|----------------|
| `scaffold-route` | New Next.js feature (page + API + validation) | "scaffold a route for bookings" |
| `prototype` | Quick React demo, shareable single HTML | "prototype a color picker" |
| `mcp` | Build MCP server for Claude integrations | "create an MCP server for my database" |
| `documents` | Generate PDFs or Word docs | "generate an invoice PDF" |
| `threejs` | 3D scenes, product viewers, animations | "build a 3D product viewer" |
| `visx` | Data visualization, charts, graphs | "create a line chart for sales data" |
| `infopage` | Quick reference HTML pages | "create an infopage comparing X vs Y" |

## Reviewing

| Skill | When to use | Example prompt |
|-------|-------------|----------------|
| `preflight` | Before PR, catch common issues | "run preflight" |
| `test-review` | Check test quality and coverage | "review my tests" |
| `zod-extract` | Find inline schemas to centralize | "find inline zod schemas" |

## Design

| Skill | When to use | Example prompt |
|-------|-------------|----------------|
| `creative-design` | Landing pages, portfolios, distinctive UI | "design a memorable landing page" |

## Quick Decision Guide

```
Need to build something?
├── Full app with database → audreygen
├── New feature in existing app → scaffold-route
├── Quick interactive demo → prototype
├── Extend Claude's capabilities → mcp
├── 3D scene or animation → threejs
├── Data visualization → visx
└── Quick reference page → infopage

Need to review something?
├── Before PR → preflight
├── Test quality → test-review
└── Schema organization → zod-extract

Need design direction?
├── Consistent app UI → your standard patterns
└── Distinctive one-off → creative-design
```
