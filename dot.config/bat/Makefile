include ../../common.mk

$(call dl-gh-raw,bluz71/fly16-bat,master,fly16.tmTheme,themes/fly16.tmTheme)

$(call install,00644,config)
$(call install,00644,themes/fly16.tmTheme)
$(call install-cmd,$(if $(CFG_APP_BAT),../../apps/cargo/bin/bat,bat) cache --build)
