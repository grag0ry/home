include common.mk

$(call subdir,dot.config)
$(call subdir,dot.local)

$(call m4,dot.bash_profile)
$(call m4,dot.bashrc)

install: dot.bashrc dot.bash_profile
	install -m 00644 -D -T dot.bashrc "$(DESTDIR)$(HOMEDIR)/.bashrc"
	install -m 00644 -D -T dot.bash_profile "$(DESTDIR)$(HOMEDIR)/.bash_profile"
	install -m 00644 -D -T dot.tmux.conf "$(DESTDIR)$(HOMEDIR)/.tmux.conf"

clean:
	$(RM) config.mk
