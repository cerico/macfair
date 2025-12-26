.PHONY: _commands _git _env

_commands:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | grep -v '[%/]' | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
	@for file in makefiles/*.mk; do \
		grep '^[[:alpha:]][^:[:space:]]*:' "$$file" | cut -d ':' -f 1 | sort -u | sed 's/^/make /'; \
	done

_git:
	@echo "Git branch:      $$(git branch --show-current 2>/dev/null || echo '')"
	@echo "Uncommitted:     $$(git status --short 2>/dev/null | wc -l | tr -d ' ') files"
	@echo ""
	@echo "Recent commits:"
	@branch=$$(git branch --show-current 2>/dev/null); \
	mainbranch="main"; \
	if [ -z "$$branch" ] || ! git rev-parse HEAD >/dev/null 2>&1; then \
		echo "  "; \
	elif [ "$$branch" = "$$mainbranch" ] || ! git rev-parse $$mainbranch >/dev/null 2>&1; then \
		git log --pretty=format:"  %ar %s" 2>/dev/null | head -5 | sed -E "s/([a-zA-Z0-9]+(\([a-zA-Z0-9]+\))?:)/\x1b[36m\1\x1b[0m/"; \
		echo ""; \
	else \
		git log $$mainbranch.. --pretty=format:"  %ar %s" 2>/dev/null | awk -v br="$$branch" '{print $$0 " ➜ " br}' | sed -E "s/([a-zA-Z0-9]+(\([a-zA-Z0-9]+\))?:)/\x1b[36m\1\x1b[0m/; s/(➜ .*)/\x1b[32m\1\x1b[0m/"; \
		git log $$mainbranch --pretty=format:"  %ar %s" 2>/dev/null | head -1 | awk -v mb="$$mainbranch" '{print $$0 " ➜ " mb}' | sed -E "s/([a-zA-Z0-9]+(\([a-zA-Z0-9]+\))?:)/\x1b[36m\1\x1b[0m/; s/(➜ .*)/\x1b[32m\1\x1b[0m/"; \
		echo ""; \
	fi

_env:
	@if [ ! -f .env ] || [ ! -f .env.test ]; then \
		$(MAKE) keys; \
	fi
	@echo "🔐 Checking environment variables..."
	@for env_file in .env .env.test; do \
		echo ""; \
		echo "Checking $$env_file:"; \
		echo "----------------"; \
		present=0; \
		empty=0; \
		for var in $(ENV_VARS); do \
			key=$${var%%=*}; \
			if grep -q "^$$key=$$" $$env_file 2>/dev/null; then \
				echo "⚠️  $$key="; \
				empty=$$((empty + 1)); \
			else \
				val=$$(grep "^$$key=" $$env_file | cut -d'=' -f2-); \
				echo "✅ $$key=$$val"; \
				present=$$((present + 1)); \
			fi; \
		done; \
		for key in $(KEYS); do \
			if grep -q "^$$key=$$" $$env_file 2>/dev/null; then \
				echo "⚠️  $$key="; \
				empty=$$((empty + 1)); \
			else \
				val=$$(grep "^$$key=" $$env_file | cut -d'=' -f2-); \
				echo "✅ $$key=$$val"; \
				present=$$((present + 1)); \
			fi; \
		done; \
		echo ""; \
		echo "Summary for $$env_file:"; \
		echo "  ✅ $$present present"; \
		echo "  ⚠️  $$empty empty"; \
	done
