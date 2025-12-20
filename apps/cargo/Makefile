include ../../common.mk

export RUSTUP_HOME := $(abspath rustup)
export CARGO_HOME := $(abspath .)
export RUSTUP_INIT_SKIP_PATH_CHECK = yes
export PATH := $(abspath bin):$(PATH)

rustup-export = $(eval $(call rustup-export-impl,$1))

rustup/rustup-init.sh:
	mkdir -p rustup
	$(call wget,https://sh.rustup.rs,$@)
	chmod +x "$@"

bin/rustup: rustup/rustup-init.sh
	"$<" -y --no-modify-path --default-toolchain none

bin/cargo: bin/rustup
	bin/rustup toolchain install stable

APPS = \
	 $(if $(CFG_APP_RIPGREP),ripgrep) \
	 $(if $(CFG_APP_FD),fd-find) \
	 $(if $(CFG_APP_EZA),eza) \
	 $(if $(CFG_APP_BAT),bat) \
	 $(if $(CFG_APP_GIT_DELTA),git-delta)

ifneq ($(strip $(APPS)),)
build: bin/cargo
	bin/cargo install $(APPS)

$(if $(CFG_APP_RIPGREP),$(call install,00755,bin/rg,.local/bin/rg))
$(if $(CFG_APP_FD),$(call install,00755,bin/fd,.local/bin/fd))
$(if $(CFG_APP_EZA),$(call install,00755,bin/eza,.local/bin/eza))
$(if $(CFG_APP_BAT),$(call install,00755,bin/bat,.local/bin/bat))
$(if $(CFG_APP_GIT_DELTA),$(call install,00755,bin/delta,.local/bin/delta))
endif

clean:
	find -maxdepth 1 -not -name Makefile -not -name . -print0 | xargs -0r rm -rf
