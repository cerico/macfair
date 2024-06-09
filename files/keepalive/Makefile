tldr:
	@echo Available commands
	@echo ------------------
	@grep '^[[:alpha:]][^:[:space:]]*:' Makefile | cut -d ':' -f 1 | sort -u | sed 's/^/make /'
%:
	@$(MAKE) tldr
cron:
	@echo Run "crontab -e", and add the following line
	@echo "22 10 * * *" `which node` `pwd`/index.mjs
install:
	npm run install
run:
	node index.mjs
