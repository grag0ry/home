include ../../../common.mk

Bibata-Original-Ice.tar.xz:
	$(call github-assets,ful1e5/Bibata_Cursor,$@,Bibata-Original-Ice\.tar\.xz)

$(call fake,bibata-extracted)
bibata-extracted: Bibata-Original-Ice.tar.xz
	tar -xvf "$<"

build: $(fake-bibata-extracted)

$(call install-dir,Bibata-Original-Ice)

clean:
	$(RM) "Bibata-Original-Ice.tar.xz"
	$(RM) -r Bibata-Original-Ice

$(call update-simple)
