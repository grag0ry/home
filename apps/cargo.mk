# Assumes the including Makefile lives one level below apps/ (apps/<name>/Makefile),
# so that ../cargo/ always resolves to the shared toolchain in apps/cargo/.

export CARGO_HOME := $(abspath ../cargo)
export PATH := $(abspath ../cargo/bin):$(PATH)

.PHONY: cargo

ifeq ($(CFG_CARGO_NATIVE),)
export RUSTUP_HOME := $(abspath ../cargo/rustup)
export RUSTUP_INIT_SKIP_PATH_CHECK = yes

../cargo/rustup/rustup-init.sh:
	mkdir -p "$(dir $@)"
	$(call wget,https://sh.rustup.rs,$@)
	chmod +x "$@"

../cargo/bin/rustup: ../cargo/rustup/rustup-init.sh
	"$<" -y --no-modify-path --default-toolchain none

../cargo/bin/cargo: ../cargo/bin/rustup
	"$<" toolchain install stable

cargo: ../cargo/bin/cargo
endif
