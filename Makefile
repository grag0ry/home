include common.mk

$(call subdir,dot.config)
$(call subdir,dot.local)

ifneq ($(origin CFG_GNUPG_AGENT), undefined)
$(call subdir,dot.gnupg)
endif

$(call m4,dot.bash_profile)
$(call m4,dot.bashrc)

$(call install,00644,dot.bashrc)
$(call install,00644,dot.bash_profile)
$(call install,00644,dot.bash_logout)
$(call install,00644,dot.tmux.conf)
$(call install,00644,dot.gitconfig)
$(call install,00644,dot.gitignore)

clean:
	$(RM) config.mk
	$(RM) config.mk.old
