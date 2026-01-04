include ../../common.mk

ifneq ($(CFG_WSL),)
$(call install,00755,wslsshagent)
$(call install,00755,wslwrap)
$(call install,00755,wslenv)
$(call install-symlink,wslwrap,git)
endif

$(call install,00755,crc32)
$(call install,00755,colors256-test)
$(call install,00755,dr)
$(call install,00755,totp)
$(call install,00755,git-fzf)
$(call install,00755,udm)
