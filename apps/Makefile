include ../common.mk

$(call subdir,cargo)
ifneq ($(CFG_LEMONADE_SERVER),)
$(call subdir,lemonade)
endif
ifneq ($(CFG_APP_NNN),)
$(call subdir,nnn)
endif
ifneq ($(CFG_APP_FZF),)
$(call subdir,fzf)
endif
