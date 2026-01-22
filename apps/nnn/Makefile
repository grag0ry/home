include ../../common.mk

.PHONY: clean
clean:
	$(RM) nnn-nerd-static.tar.gz nnn-static.tar.gz nnn-nerd-static nnn-static

nnn-nerd-static.tar.gz nnn-static.tar.gz:
	$(call github-assets,jarun/nnn,$@,$(@:%.tar.gz=%))

nnn-nerd-static nnn-static: %: %.tar.gz
	tar xzf "$<" "$@"
	touch "$@"

.PHONY: build
build: nnn-nerd-static nnn-static

$(call install,00755,nnn-nerd-static,.local/bin/nnn-nerd-static)
$(call install,00755,nnn-static,.local/bin/nnn-static)
