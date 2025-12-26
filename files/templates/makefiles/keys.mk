.PHONY: keys

keys:
	@for envfile in .env .env.test; do \
		if [ ! -f $$envfile ]; then \
			touch $$envfile; \
		fi; \
		for var in $(ENV_VARS); do \
			key=$${var%%=*}; \
			if ! grep -q "^$$key=" $$envfile 2>/dev/null; then \
				echo "$$var" >> $$envfile; \
				echo "✓ Added $$key to $$envfile"; \
			fi; \
		done; \
		for key in $(KEYS); do \
			if ! grep -q "^$$key=" $$envfile 2>/dev/null; then \
				echo "$$key=" >> $$envfile; \
				echo "✓ Added $$key to $$envfile"; \
			fi; \
		done; \
	done
	@echo "✓ Environment files updated"
