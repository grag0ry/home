include ../../common.mk

$(call m4,env.bash)

SRC = env.bash
ifneq ($(origin CFG_WSL), undefined)
	SRC += wsl.profile.bash
endif

install: $(SRC)
	install -m 00644 -D -t "$(DESTDIR)$(CFG_HOME)/.config/bash" $(SRC)
