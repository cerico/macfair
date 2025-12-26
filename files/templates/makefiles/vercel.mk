.PHONY: vercel

vercel:
	@if ! git remote get-url origin >/dev/null 2>&1; then \
		echo "Step 1/5: Creating GitHub repository..."; \
		gh repo create --source=. --push --private; \
		echo ""; \
	else \
		echo "Step 1/5: GitHub repository exists ✓"; \
		echo ""; \
	fi
	@if [ -f .vercel/project.json ]; then \
		echo "Step 2/5: Vercel project linked ✓"; \
	else \
		echo "Step 2/5: Linking Vercel project..."; \
		npx vercel link; \
	fi
	@echo ""
	@if gh secret list | grep -q DATABASE_URL; then \
		echo "Step 3/5: DATABASE_URL already set ✓"; \
	else \
		echo "Step 3/5: Setting up Neon database..."; \
		npx vercel integration add neon; \
		echo ""; \
		echo "📌 Create and connect a database in the Vercel Storage tab"; \
		while true; do \
			read -p "Paste your DATABASE_URL: " db_url; \
			if echo "$$db_url" | grep -q "^postgres"; then \
				echo "$$db_url" | gh secret set DATABASE_URL; \
				break; \
			else \
				echo "Invalid URL - must start with postgres://"; \
			fi; \
		done; \
	fi
	@echo ""
	@if gh secret list | grep -q VERCEL_TOKEN; then \
		echo "Step 4/5: VERCEL_TOKEN already set ✓"; \
	else \
		echo "Step 4/5: Opening Vercel to create a token..."; \
		open https://vercel.com/account/tokens; \
		read -p "Paste your VERCEL_TOKEN: " token && \
		gh secret set VERCEL_TOKEN --body "$$token"; \
	fi
	@echo ""
	@if gh secret list | grep -q VERCEL_ORG_ID && gh secret list | grep -q VERCEL_PROJECT_ID; then \
		echo "Step 5/5: Vercel secrets already set ✓"; \
	else \
		echo "Step 5/5: Setting GitHub secrets..."; \
		gh secret set VERCEL_ORG_ID --body "$$(jq -r '.orgId' .vercel/project.json)"; \
		gh secret set VERCEL_PROJECT_ID --body "$$(jq -r '.projectId' .vercel/project.json)"; \
	fi
	@echo ""
	@echo "✅ Vercel deployment configured!"
