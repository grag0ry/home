include ../../common.mk

.PHONY: build
build: lemonade

.PHONY: clean
clean:
	$(RM) lemonade_linux_amd64.tar.gz lemonade

lemonade_linux_amd64.tar.gz:
	$(call github-assets,lemonade-command/lemonade,$@,$@)

lemonade: lemonade_linux_amd64.tar.gz
	tar xzf lemonade_linux_amd64.tar.gz
	touch "$@"

$(call install,00755,lemonade,.local/bin/lemonade)

