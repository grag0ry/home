include common.mk

$(call subdir,dot.config)
$(call subdir,dot.local)

$(call m4,dot.bash_profile)
$(call m4,dot.bashrc)

install: dot.bashrc dot.bash_profile
	install -m 00644 -D -T dot.bashrc "$(DESTDIR)$(CFG_HOME)/.bashrc"
	install -m 00644 -D -T dot.bash_profile "$(DESTDIR)$(CFG_HOME)/.bash_profile"
	install -m 00644 -D -T dot.tmux.conf "$(DESTDIR)$(CFG_HOME)/.tmux.conf"

clean:
	$(RM) config.mk
