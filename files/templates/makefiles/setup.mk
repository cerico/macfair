.PHONY: setup

setup:
	@echo "🚀 Setting up $(shell basename $(CURDIR))..."
	@echo ""
	@echo "Step 1/3: Checking prerequisites..."
	@command -v node >/dev/null 2>&1 || { echo "❌ Node.js is not installed. Install from https://nodejs.org"; exit 1; }
	@echo "  ✅ Node.js $(shell node --version)"
	@command -v pnpm >/dev/null 2>&1 || { echo "⚠️  pnpm not found, will install..."; npm install -g pnpm; }
	@echo "  ✅ pnpm $(shell pnpm --version)"
	@echo ""
	@echo "Step 2/3: Installing dependencies..."
	@$(MAKE) install
	@echo ""
	@echo "Step 3/3: Verifying setup..."
	@$(MAKE) health
	@echo ""
	@echo "🎉 Setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Review .env file and add any missing API keys"
	@echo "  2. Run 'make dev' to start the development server"
	@echo "  3. Run 'make tldr' to see all available commands"
	@echo ""
