include ../../common.mk

.PHONY: build
build: hmacseal

.PHONY: clean
clean:
	$(RM) hmacd-x86_64-pc-windows-msvc.zip hmacd-x86_64-unknown-linux-gnu.tar.gz hmacseal-x86_64-unknown-linux-musl.tar.gz \
		hmacd hmacseal hmacd.exe

hmacd-x86_64-pc-windows-msvc.zip hmacd-x86_64-unknown-linux-gnu.tar.gz hmacseal-x86_64-unknown-linux-musl.tar.gz:
	$(call github-assets,grag0ry/hmacseal,$@,$@)

hmacd: hmacd-x86_64-unknown-linux-gnu.tar.gz
	tar xzf "$<" "$@"
	touch "$@"

hmacseal: hmacseal-x86_64-unknown-linux-musl.tar.gz
	tar xzf "$<" "$@"
	touch "$@"

hmacd.exe: hmacd-x86_64-pc-windows-msvc.zip
	unzip -o "$<" "$@"
	touch "$@"

$(call install,00755,hmacseal,.local/bin/hmacseal)

ifneq ($(CFG_HMACD),)
ifneq ($(CFG_WSL),)
build: hmacd.exe
$(call install,00755,hmacd.exe,.local/bin/hmacd.exe)
endif
endif

$(call update-simple)
