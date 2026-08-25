include ../../common.mk
include ../cargo.mk

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

update: cargo
	cargo install $(cargo-apps)
	$(MAKE) install

