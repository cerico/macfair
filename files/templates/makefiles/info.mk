.PHONY: health clean info

health:
	@echo "🔍 Checking development environment..."
	@command -v pnpm >/dev/null && echo "✅ pnpm installed" || echo "❌ pnpm missing"
	@command -v node >/dev/null && echo "✅ node installed ($$(node --version))" || echo "❌ node missing"
	@[ -f .env ] && echo "✅ .env exists" || echo "⚠️  .env missing"
	@[ -d node_modules ] && echo "✅ node_modules installed" || echo "❌ node_modules missing"
	@echo ""
	@$(MAKE) _env

clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf node_modules
	@echo "✅ Cleaned"

info:
	@echo "📮 Project Information"
	@echo "----------------------"
	@echo "Node version:    $$(node --version)"
	@echo "pnpm version:    $$(pnpm --version)"
	@echo "App version:     $$([[ -f package.json ]] && node -p "require('./package.json').version")"
	@$(MAKE) _git
