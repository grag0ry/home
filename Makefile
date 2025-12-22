include common.mk

$(call subdir,dot.config)
$(call subdir,dot.local)
$(call subdir,apps)

ifneq ($(CFG_GNUPG_AGENT),)
$(call subdir,dot.gnupg)
endif

$(call m4,dot.bash_profile)
$(call m4,dot.bashrc)
$(call m4,dot.tmux.conf)
$(call m4,dot.gitconfig)

$(call install,00644,dot.bashrc)
$(call install,00644,dot.bash_profile)
$(call install,00644,dot.bash_logout)
$(call install,00644,dot.tmux.conf)
$(call install,00644,dot.gitconfig)
$(call install,00644,dot.gitignore)

.PHONY: uninstall
uninstall:
ifeq ($(wildcard $(idxfile-dir)),$(idxfile-dir))
	cd $(DESTDIR)$(CFG_HOME) && while IFS= read -r file; do \
		rm -vf "$$file"; dir=$$(dirname "$$file"); \
		[[ $$dir != . && -d $$dir ]] \
			&& rmdir -pv "$$dir" || : ; \
	done < <( cat "$(idxfile-dir)"/* )
	rm -rvf "$(idxfile-dir)"
else
	$(error Not installed)
endif

