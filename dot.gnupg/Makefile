include ../common.mk

SRC = gpg-agent.conf gpg.conf

install: $(SRC)
	install -m 00644 -D -t "$(DESTDIR)$(CFG_HOME)/.gnupg" $(SRC)
