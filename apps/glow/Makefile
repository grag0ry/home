include ../../common.mk

.PHONY: clean
clean:
	$(RM) glow glow_linux_amd64.tar.gz

glow_linux_amd64.tar.gz:
	$(call github-assets,charmbracelet/glow,$@,glow_.*_Linux_x86_64\.tar\.gz$$)

glow: glow_linux_amd64.tar.gz
	tar xzf "$<" --strip-components=1 --wildcards '*/glow'
	touch "$@"

.PHONY: build
build: glow

$(call install,00755,glow,.local/bin/glow)

$(call update-simple)
