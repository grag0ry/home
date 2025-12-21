include ../../common.mk

export CARGO_HOME := $(abspath .)
export PATH := $(abspath bin):$(PATH)

.PHONY: cargo

ifeq ($(CFG_CARGO_NATIVE),)
export RUSTUP_HOME := $(abspath rustup)
export RUSTUP_INIT_SKIP_PATH_CHECK = yes

rustup-export = $(eval $(call rustup-export-impl,$1))

rustup/rustup-init.sh:
	mkdir -p rustup
	$(call wget,https://sh.rustup.rs,$@)
	chmod +x "$@"

bin/rustup: rustup/rustup-init.sh
	"$<" -y --no-modify-path --default-toolchain none

bin/cargo: bin/rustup
	bin/rustup toolchain install stable

cargo: bin/cargo
endif

$(call fake,cargo-apps)
cargo-apps =
cargo-apps: cargo
	cargo install $(cargo-apps)

define app-target=
ifneq ($$($1),)
cargo-apps += $2
bin/$3: $(fake-cargo-apps)
build: bin/$3
$$(call install,00755,bin/$3,.local/bin/$3)
endif
endef
app = $(eval $(call app-target,$1,$2,$(if $3,$3,$2)))

$(call app,CFG_APP_RIPGREP,ripgrep,rg)
$(call app,CFG_APP_FD,fd-find,fd)
$(call app,CFG_APP_EZA,eza)
$(call app,CFG_APP_BAT,bat)
$(call app,CFG_APP_GIT_DELTA,git-delta,delta)
$(call app,CFG_APP_HEXYL,hexyl)

clean:
	find -maxdepth 1 -not -name .gitignore -not -name Makefile -not -name . -print0 | xargs -0r rm -rf
