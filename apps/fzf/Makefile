include ../../common.mk

.PHONY: clean
clean:
	$(RM) fzf fzf-linux_amd64.tar.gz

fzf-linux_amd64.tar.gz:
	$(call github-assets,junegunn/fzf,$@,fzf-[0-9.]*-linux_amd64.tar.gz)

fzf: fzf-linux_amd64.tar.gz
	tar xzf "$<" "$@"
	touch "$@"

.PHONY: build
build: fzf

$(call install,00755,fzf)
