include ../../../common.mk

.PHONY: build
build: lemonade

.PHONY: install
install: lemonade
	install -m 00755 -s -D -t "$(DESTDIR)$(CFG_HOME)/.local/bin" "$<"

.PHONY: clean
clean:
	$(RM) lemonade_linux_amd64.tar.gz lemonade

lemonade_linux_amd64.tar.gz:
	$(TOOLS)github-assets.sh lemonade-command/lemonade \
		| grep lemonade_linux_amd64.tar.gz \
		| xargs -r curl -s -L -o "$@"

lemonade: lemonade_linux_amd64.tar.gz
	tar xzf lemonade_linux_amd64.tar.gz
	touch "$@"
