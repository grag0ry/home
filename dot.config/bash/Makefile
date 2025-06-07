include ../../common.mk

$(call m4,env.bash)

$(call install,00644,env.bash)
ifneq ($(origin CFG_WSL), undefined)
$(call install,00644,wsl.profile.bash)
endif
