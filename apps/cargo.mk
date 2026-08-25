# Assumes the including Makefile lives one level below apps/ (apps/<name>/Makefile).
# Include AFTER ../../common.mk: it needs CFG_CARGO_NATIVE from config.mk.

export CARGO_HOME := $(abspath ../cargo)

.PHONY: cargo

ifeq ($(CFG_CARGO_NATIVE),)
export PATH := $(abspath ../cargo/bin):$(PATH)
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
