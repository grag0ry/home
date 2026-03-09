include ../../../common.mk

nerd-DejaVuSansMono.tar.xz:
	$(call github-assets,ryanoasis/nerd-fonts,$@,DejaVuSansMono\.tar\.xz)

NotoColorEmoji.ttf:
	$(call wget,https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf,$@)

$(call fake,nerd-extracted)
nerd-extracted: nerd-DejaVuSansMono.tar.xz
	tar --wildcards -xvf "$<" '*.ttf'

build: $(fake-nerd-extracted) NotoColorEmoji.ttf

$(call install-wildcard,00644,*.ttf)

clean:
	$(RM) "nerd-DejaVuSansMono.tar.xz" ".nerd-extracted"
	$(RM) *.ttf

$(call update-simple)
