---
name: mcp
description: Build MCP (Model Context Protocol) servers to extend Claude's capabilities with database access, API integrations, or custom tools.
---

# MCP

Build MCP servers that give Claude access to external tools and data.

## What is MCP?

Model Context Protocol lets you create servers that Claude can call:
- Query databases
- Call APIs
- Access file systems
- Run custom tools

## When to Build an MCP Server

- You want Claude to access live data (not just files)
- You're repeating the same API calls manually
- You want Claude to take actions (create records, trigger workflows)

## Project Setup

```bash
mkdir my-mcp-server && cd my-mcp-server
pnpm init
pnpm add @modelcontextprotocol/sdk zod
pnpm add -D typescript @types/node tsx
```

```json
// package.json
{
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js"
  }
}
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "dist",
    "strict": true,
    "esModuleInterop": true
  },
  "include": ["src"]
}
```

## Basic Server Template

```typescript
// src/index.ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js'
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js'
import { z } from 'zod'

const server = new McpServer({
  name: 'my-server',
  version: '1.0.0',
})

// Define a tool
server.tool(
  'hello',
  'Say hello to someone',
  { name: z.string().describe('Name to greet') },
  async ({ name }) => ({
    content: [{ type: 'text', text: `Hello, ${name}!` }],
  })
)

// Start server
const transport = new StdioServerTransport()
await server.connect(transport)
```

## Common Patterns

### Database Access (Postgres)

```typescript
import pg from 'pg'

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL,
})

server.tool(
  'query',
  'Run a read-only SQL query',
  { sql: z.string().describe('SELECT query to run') },
  async ({ sql }) => {
    if (!sql.trim().toLowerCase().startsWith('select')) {
      return { content: [{ type: 'text', text: 'Only SELECT queries allowed' }] }
    }
    const result = await pool.query(sql)
    return { content: [{ type: 'text', text: JSON.stringify(result.rows, null, 2) }] }
  }
)
```

### API Wrapper

```typescript
server.tool(
  'get_weather',
  'Get current weather for a city',
  { city: z.string() },
  async ({ city }) => {
    const res = await fetch(`https://api.weather.com/current?city=${city}`)
    const data = await res.json()
    return { content: [{ type: 'text', text: JSON.stringify(data, null, 2) }] }
  }
)
```

### File System Access

```typescript
import { readdir, readFile } from 'fs/promises'

server.tool(
  'list_projects',
  'List projects in studio-manager',
  {},
  async () => {
    const dirs = await readdir('/Users/brew/studio-manager', { withFileTypes: true })
    const projects = dirs.filter(d => d.isDirectory()).map(d => d.name)
    return { content: [{ type: 'text', text: projects.join('\n') }] }
  }
)
```

## Claude Desktop Config

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/my-mcp-server/dist/index.js"],
      "env": {
        "DATABASE_URL": "postgres://..."
      }
    }
  }
}
```

Restart Claude Desktop after changes.

## Testing

```bash
# Run server directly to test
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | pnpm start
```

## Security Notes

- Validate all inputs with Zod
- Limit database access to SELECT only (unless intentional)
- Don't expose secrets in tool responses
- Consider rate limiting for external APIs

## Reference

- MCP Docs: https://modelcontextprotocol.io/docs
- MCP SDK: https://github.com/modelcontextprotocol/sdk
- Anthropic's mcp-builder: https://github.com/anthropics/skills/tree/main/skills/mcp-builder
