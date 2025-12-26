.PHONY: playwright

playwright:
	@if [ ! -f .env.test ]; then \
		echo "❌ .env.test not found"; \
		echo "Run 'make db' to set up databases and environment files"; \
		exit 1; \
	fi
	@echo "Resetting test database..."
	@DATABASE_URL=postgresql://$(TEST_DB_USER):$(TEST_DB_PASSWORD)@localhost:5432/$(TEST_DATABASE_URL) NODE_ENV=test npx prisma migrate reset --force || \
	{ echo "❌ Database reset failed. Is PostgreSQL running?"; exit 1; }
	@DATABASE_URL=postgresql://$(TEST_DB_USER):$(TEST_DB_PASSWORD)@localhost:5432/$(TEST_DATABASE_URL) NODE_ENV=test npx tsx prisma/seed.playwright.ts || \
	{ echo "❌ Seeding failed. Check prisma/seed.playwright.ts for errors"; exit 1; }
	@set -a && . .env.test && set +a && \
	if [ -n "$(TEST)" ]; then \
		echo "Running playwright test: $(TEST)"; \
		npx playwright test --ui tests/playwright/**/$(TEST); \
	elif [ -n "$(SUITE)" ]; then \
		echo "Running playwright tests for suite: $(SUITE)"; \
		npx playwright test tests/playwright/$(SUITE); \
	else \
		echo "Running all playwright tests"; \
		npx playwright test; \
	fi
