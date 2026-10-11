include ../../common.mk

sshseal-x86_64-unknown-linux-musl.tar.gz:
	$(call github-assets,grag0ry/sshseal,$@,linux-musl\.tar\.gz)

sshseal: sshseal-x86_64-unknown-linux-musl.tar.gz
	tar xzf "$<" "$@"
	touch "$@"

.PHONY: build
build: sshseal

.PHONY: clean
clean:
	$(RM) sshseal sshseal-x86_64-unknown-linux-musl.tar.gz

$(call install,00755,sshseal,.local/bin/sshseal)
$(call update-simple)
