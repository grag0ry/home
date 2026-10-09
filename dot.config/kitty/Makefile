include ../../common.mk

$(call dl-gh-raw,bluz71/vim-moonfly-colors,master,extras/moonfly-kitty.conf)
$(call m4,kitty.conf)
kitty.conf: moonfly-kitty.conf
$(call install,00644,kitty.conf)
