include ../../common.mk

.PHONY: build
build: lemonade

.PHONY: clean
clean:
	$(RM) lemonade_linux_amd64.tar.gz lemonade_windows_amd64.zip lemonade lemonade.exe

lemonade_linux_amd64.tar.gz:
	$(call github-assets,lemonade-command/lemonade,$@,$@)

lemonade_windows_amd64.zip:
	$(call github-assets,lemonade-command/lemonade,$@,$@)

lemonade: lemonade_linux_amd64.tar.gz
	tar xzf "$<" "$@"
	touch "$@"

lemonade.exe: lemonade_windows_amd64.zip
	unzip -o "$<" "$@"
	touch "$@"

$(call install,00755,lemonade,.local/bin/lemonade)

ifneq ($(CFG_WSL),)
ifneq ($(CFG_LEMONADE_SERVER),)
build: lemonade.exe
$(call install,00755,lemonade.exe,.local/bin/lemonade.exe)
endif
endif

$(call update-simple)
