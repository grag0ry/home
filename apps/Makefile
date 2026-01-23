include ../common.mk

$(call subdir,cargo)
$(call subdir,lemonade)
ifneq ($(CFG_APP_NNN),)
$(call subdir,nnn)
endif
ifneq ($(CFG_APP_FZF),)
$(call subdir,fzf)
endif
