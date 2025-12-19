.PHONY: default
default: build

.PHONY: build install clean

PRJROOT = $(dir $(lastword $(MAKEFILE_LIST)))
TOOLS = $(PRJROOT)tools/
CONFIG = $(PRJROOT)config.mk

-include $(CONFIG)

.PHONY: config
config:
	$(TOOLS)makeconf.sh > "$(CONFIG)"

$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(eval config: export $v=$($v)))

.PHONY: print-config
print-config:
	@cat "$(CONFIG)"

define NL=


endef

M4=m4 -P $(foreach v,$(filter CFG_%, $(.VARIABLES)),$(if $($v),-D"m4_$(v)=$($(v))"))

define subdir-target =
.PHONY: $1-build $1-install $1-clean
$1-build:
	$$(MAKE) -C "$1" build

$1-install:
	$$(MAKE) -C "$1" install

$1-clean:
	$$(MAKE) -C "$1" clean

install: $1-install
build: $1-build
clean: $1-clean
endef

define m4-target =
.PHONY: $1-clean
$1: $1.in $$(CONFIG)
	$$(M4) $$(M4ARGS) $2 "$1.in" > "$$@"

$1-clean:
	$$(RM) "$1"

build: $1
clean: $1-clean
endef

define install-target =
install-receipt += $$(NL)install -m $1 -D -T "$2" "$$(DESTDIR)$$(CFG_HOME)/$3"
install: $2
endef

define install-wildcard-target =
install-receipt += $$(NL)install -m $1 -D -t "$$(DESTDIR)$$(CFG_HOME)/$(dir $3)" $2
install: build
endef

define install-symlink-target =
install-receipt += $$(NL)ln -sf "$1" "$$(DESTDIR)$$(CFG_HOME)/$(dir $3)$2"
endef

define install-cmd-target =
install-receipt += $$(NL)cd "$$(DESTDIR)$$(CFG_HOME)/" && $1
endef

install:
	$(install-receipt)

subdir = $(eval $(call subdir-target,$1))
m4 = $(eval $(call m4-target,$1,$2))
install-path = $(subst dot.,.,$(patsubst $(abspath $(PRJROOT))/%,%,$(abspath $1)))
install = $(eval $(call install-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-wildcard = $(eval $(call install-wildcard-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-symlink = $(eval $(call install-symlink-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-cmd=$(eval $(call install-cmd-target,$1))
find = $(wildcard $1/$2) $(foreach d,$(wildcard $(1:=/*/)),$(call find,$(d:/=),$2))
uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
