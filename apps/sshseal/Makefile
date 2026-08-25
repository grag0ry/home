include ../../common.mk
include ../cargo.mk

.PHONY: build
build: cargo
	cargo build --release

$(call install,00755,target/release/sshseal,.local/bin/sshseal)

.PHONY: clean
clean:
	cargo clean

.PHONY: update
update: cargo
	cargo update
	$(MAKE) clean
	$(MAKE) build
	$(MAKE) install
