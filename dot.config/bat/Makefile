include ../../common.mk

$(call install,00644,config)
$(call install,00644,themes/Moonfly.tmTheme)
$(call install-cmd,$(if $(CFG_APP_BAT),../../apps/cargo/bin/bat,bat) cache --build)
