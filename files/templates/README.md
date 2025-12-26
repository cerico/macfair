# Herceg Novi

## TLDR

```bash
make          # Show project info and available commands
make setup    # Install dependencies and run health check
make dev      # Start development server
make info     # Show project information
make health   # Check development environment
```

## Commands

| Command | Description |
|---------|-------------|
| `make setup` | Full project setup (prereqs, dependencies) |
| `make dev` | Start development server (port 6150) |
| `make build` | Build for production |
| `make stop` | Stop the dev server |
| `make install` | Install dependencies |
| `make info` | Show project information |
| `make health` | Check development environment |
| `make clean` | Remove build artifacts |

### Git

| Command | Description |
|---------|-------------|
| `make amend` | Amend last commit (blocked on main) |
| `make squash` | Squash branch commits into one |

## Prerequisites

- Node.js 22+ (`brew install node`)
- pnpm (installed automatically by `make setup`)

## What Setup Does

The `make setup` command:

1. Checks prerequisites (Node.js, pnpm)
2. Installs dependencies
3. Runs health check to verify everything works
