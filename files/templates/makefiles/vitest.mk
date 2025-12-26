.PHONY: vitest

vitest:
	@if [ ! -f .env.test ]; then \
		echo "❌ .env.test not found"; \
		echo "Run 'make db' to set up databases and environment files"; \
		exit 1; \
	fi
	@echo "🗄️  Resetting test database..."
	@DATABASE_URL=postgresql://$(TEST_DB_USER):$(TEST_DB_PASSWORD)@localhost:5432/$(TEST_DATABASE_URL) NODE_ENV=test pnpm exec prisma db push --force-reset || \
	{ echo "❌ Database reset failed. Is PostgreSQL running?"; exit 1; }
	@echo "🌱 Seeding test database..."
	@DATABASE_URL=postgresql://$(TEST_DB_USER):$(TEST_DB_PASSWORD)@localhost:5432/$(TEST_DATABASE_URL) NODE_ENV=test pnpm exec tsx prisma/seed.vitest.ts || \
	{ echo "❌ Seeding failed. Check prisma/seed.vitest.ts for errors"; exit 1; }
	@if [ -n "$$CI" ]; then \
		echo "🧪 Running all tests in CI"; \
		NODE_ENV=test pnpm exec vitest run; \
	else \
		echo "🎨 Opening vitest UI..."; \
		NODE_ENV=test pnpm exec vitest --ui; \
	fi
