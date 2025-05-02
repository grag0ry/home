include ../../common.mk

SCRIPTS = crc32 colors256-test

$(call subdir,lemonade)

install: $(SCRIPTS)
	install -m 00755 -D -t "$(DESTDIR)$(HOMEDIR)/.local/bin" $(SCRIPTS)
