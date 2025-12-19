include ../../../common.mk

nerd-DejaVuSansMono.tar.xz:
	$(call github-assets,ryanoasis/nerd-fonts,$@,DejaVuSansMono\.tar\.xz)

.nerd-extracted: nerd-DejaVuSansMono.tar.xz
	tar --wildcards -xvf "$<" '*.ttf'
	touch "$@"

build: .nerd-extracted

$(call install-wildcard,00644,*.ttf)

clean:
	$(RM) "nerd-DejaVuSansMono.tar.xz" ".nerd-extracted"
	$(RM) *.ttf

