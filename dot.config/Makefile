include ../common.mk

$(call subdir,bash)
$(call subdir,autofs)
$(call subdir,ripgrep)
$(call subdir,delta)
$(call subdir,glow)
$(call subdir,bat)
$(call subdir,openrc-0)
ifneq ($(CFG_X),)
$(call subdir,kitty)
$(call subdir,gsettings)
endif
ifneq ($(CFG_LEMONADE_WSL_PRIVATE),)
$(call install,00644,lemonade-wsl-private.toml,.config/lemonade.toml)
endif
