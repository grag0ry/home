include ../../common.mk

$(call m4,env.d/path.bash)
$(call m4,profile.bash)

ENVD = env.d/bash.bash
ENVD += env.d/common.bash
ENVD += env.d/exa.bash
ENVD += env.d/path.bash
ENVD += env.d/wine.bash

SRC = bashrc.bash profile.bash
ifneq ($(origin CFG_WSL), undefined)
	SRC += wsl.profile.bash
endif

install: $(SRC) $(ENVD)
	install -m 00644 -D -t "$(DESTDIR)$(CFG_HOME)/.config/bash" $(SRC)
	install -m 00644 -D -t "$(DESTDIR)$(CFG_HOME)/.config/bash/env.d" $(ENVD)
