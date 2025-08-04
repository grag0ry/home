include ../../../common.mk

nerd-DejaVuSansMono.tar.xz:
	$(TOOLS)github-assets.sh ryanoasis/nerd-fonts \
		| grep "DejaVuSansMono\.tar\.xz" \
		| xargs -r curl -s -L -o "$@"

.nerd-extracted: nerd-DejaVuSansMono.tar.xz
	tar --wildcards -xvf "$<" '*.ttf'
	touch "$@"

build: .nerd-extracted

$(call install-wildcard,00644,*.ttf)

clean:
	$(RM) "nerd-DejaVuSansMono.tar.xz" ".nerd-extracted"
	$(RM) *.ttf

