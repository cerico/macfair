.PHONY: amend squash

amend:
	@if [ "$$(git branch --show-current)" = "main" ]; then \
		echo "❌ Cannot amend commits on main branch"; \
		exit 1; \
	fi
	git commit --amend

squash:
	@if [ "$$(git branch --show-current)" = "main" ]; then \
		echo "❌ Cannot squash commits on main branch"; \
		exit 1; \
	fi
	@MERGE_BASE=$$(git merge-base HEAD main) && \
	COMMIT_COUNT=$$(git rev-list --count $$MERGE_BASE..HEAD) && \
	[ "$$COMMIT_COUNT" -eq 1 ] && MESSAGE="commit" || MESSAGE="commits" && \
	echo "Squashing $$COMMIT_COUNT $$MESSAGE..." && \
	FIRST_COMMIT=$$(git log --reverse --format=%H $$MERGE_BASE..HEAD | head -n 1) && \
	git reset --soft $$MERGE_BASE && \
	git commit -c $$FIRST_COMMIT
