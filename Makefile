include common.mk

$(call subdir,dot.config)
$(call subdir,dot.local)
$(call subdir,dot.claude)
$(call subdir,apps)

$(call dl-gh-raw,bluz71/vim-moonfly-colors,master,extras/moonfly.tmux)

$(call m4,dot.bash_profile)
$(call m4,dot.bashrc)
$(call m4,dot.tmux.conf)
$(call m4,dot.gitconfig)

dot.tmux.conf: moonfly.tmux

$(call install,00644,dot.bashrc)
$(call install,00644,dot.bash_profile)
$(call install,00644,dot.bash_logout)
$(call install,00644,dot.tmux.conf)
$(call install,00644,dot.gitconfig)
$(call install,00644,dot.gitignore)

ifneq ($(CFG_X),)
$(call m4,dot.Xresources)
$(call install,00644,dot.Xresources)
endif

ifneq ($(CFG_DEV_RC),)
$(call m4,dot.dev-rc)
$(call install,00644,dot.dev-rc,.dev-rc)
endif
