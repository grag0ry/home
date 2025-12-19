include ../../common.mk

$(call m4,env.bash)
$(call m4,wsl.profile.bash)

$(call install,00644,env.bash)
$(call install,00644,colors.bash)
ifneq ($(CFG_WSL),)
$(call install,00644,wsl.profile.bash)
endif
