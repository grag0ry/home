include ../../../common.mk

.PHONY: build
build: lemonade

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

$(call install,00755,lemonade,.local/bin/lemonade)

