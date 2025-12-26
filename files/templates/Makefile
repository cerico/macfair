SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

PORT ?= 6150

.DEFAULT_GOAL := tldr

.PHONY: tldr dev build stop install

tldr:
	@$(MAKE) info
	@echo ""
	@$(MAKE) _commands

%:
	@$(MAKE) _commands

dev:
	@[[ -d node_modules ]] || { echo "📦 node_modules not found, running install..."; $(MAKE) install; }
	@pnpm dev

build:
	@echo "Building application..."
	pnpm build

stop:
	-@pid=$$(lsof -ti :$(PORT) 2>/dev/null); \
	[[ -z "$$pid" ]] && echo "No process running on port $(PORT)" || { echo "Stopping process on port $(PORT) (PID: $$pid)..."; kill $$pid; }

install:
	@echo "Installing dependencies with pnpm..."
	@command -v pnpm >/dev/null 2>&1 || { echo "pnpm is not installed. Installing pnpm..."; npm install -g pnpm; }
	NODE_ENV=development pnpm install
	@[[ ! -f prisma/schema.prisma ]] || pnpm prisma generate
	@echo "✅ Installation complete! Run 'make dev' to start the development server."

.env .env.test: ;
makefiles/%.mk: ;
-include .env
-include makefiles/*.mk

