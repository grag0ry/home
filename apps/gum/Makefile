include ../../common.mk

.PHONY: clean
clean:
	$(RM) gum gum_linux_amd64.tar.gz

gum_linux_amd64.tar.gz:
	$(call github-assets,charmbracelet/gum,$@,gum_.*_Linux_x86_64\.tar\.gz$$)

gum: gum_linux_amd64.tar.gz
	tar xzf "$<" --strip-components=1 --wildcards '*/gum'
	touch "$@"

.PHONY: build
build: gum

$(call install,00755,gum,.local/bin/gum)

$(call update-simple)
