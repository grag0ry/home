.PHONY: default
default: build

.PHONY: build install clean uninstall

PRJROOT = $(dir $(lastword $(MAKEFILE_LIST)))
TOOLS = $(PRJROOT)tools/
CONFIG = $(PRJROOT)config.mk
SUBDIR = $(patsubst $(abspath $(PRJROOT))/%,%,$(abspath .)/)
INSDIR = $(subst dot.,.,$(SUBDIR))


-include $(CONFIG)

ifneq ($(wildcard config),config)
.PHONY: config
config:
	$(TOOLS)makeconf.sh > "$(CONFIG)"
endif

$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(eval config: export $v=$($v)))

define NL=


endef

find = $(wildcard $1/$2) $(foreach d,$(wildcard $(1:=/*/)),$(call find,$(d:/=),$2))
uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
wget = wget --progress=dot:giga "$1" -O "$2" --no-use-server-timestamps
github-assets = $(TOOLS)github-assets.sh "$1" \
	| grep -m1 "$(if $3,$3,.*)" \
	| xargs -r -i $(call wget,{},$2)

M4=m4 -P $(foreach v,$(filter CFG_%, $(.VARIABLES)),$(if $($v),-D"m4_$(v)=$($(v))"))
define m4-target =
.PHONY: $1-clean
$1: $1.in $$(CONFIG)
	$$(M4) $$(M4ARGS) $2 "$1.in" > "$$@"

$1-clean:
	$$(RM) "$1"

build: $1
clean: $1-clean
endef
m4 = $(eval $(call m4-target,$1,$2))

define fake-target =
.PHONY: $1
fake-$1 = .fake-$1
$$(fake-$1):
	$$(MAKE) -f $$(firstword $$(MAKEFILE_LIST)) $1
	touch "$$@"

endef
fake = $(eval $(call fake-target,$1))

define subdir-target =
.PHONY: $1-build $1-install $1-clean $1-uninstall
$1-build:
	$$(MAKE) -C "$1" build

$1-install:
	$$(MAKE) -C "$1" install

$1-uninstall:
	$$(MAKE) -C "$1" uninstall

$1-clean:
	$$(MAKE) -C "$1" clean

install: $1-install
build: $1-build
clean: $1-clean
uninstall: $1-uninstall
endef
subdir = $(eval $(call subdir-target,$1))

IDXDIR = .local/lib/home/idx/
IDXNAME = $(subst /,-,$(SUBDIR)idxfile)

$(IDXNAME)::
	$(if $(install-index),: > "$@",)
	$(install-index)

.PHONY: $(IDXNAME)-clean
clean: $(IDXNAME)-clean
$(IDXNAME)-clean:
	rm -f "$(IDXNAME)"

UNINSTDIR = .local/lib/home/uninstall/
UNINSTCD = ../../../../
UNINSTNAME = $(subst /,-,$(SUBDIR)uninstall.sh)

define uninstall-sh =
#!/bin/bash
cd "$$(dirname "$$(realpath "$${BASH_SOURCE[0]}")")"/$(UNINSTCD) || exit 1
while IFS= read -r file; do
	rm -vf "$$file"
	dir=$$(dirname "$$file")
	[[ $$dir = [./] ]] || rmdir -pv --ignore-fail-on-non-empty "$$dir"
done < "$(IDXDIR)$(IDXNAME)"
rm -vf "$(IDXDIR)$(IDXNAME)"
rmdir -pv --ignore-fail-on-non-empty "$(IDXDIR)"
rm -vf "$(UNINSTDIR)$(UNINSTNAME)"
rmdir -pv --ignore-fail-on-non-empty "$(UNINSTDIR)"
endef

$(UNINSTNAME):: $(IDXNAME)
	$(if $(wildcard $(IDXNAME)),@echo "Writing $@")
	$(if $(wildcard $(IDXNAME)),$(file >$@,$(uninstall-sh)))

.PHONY: $(UNINSTNAME)-clean
clean: $(UNINSTNAME)-clean
$(UNINSTNAME)-clean:
	rm -f "$(UNINSTNAME)"

define install-target =
install-receipt += $$(NL)install -m $1 -D -T "$2" "$$(DESTDIR)$$(CFG_HOME)/$3"
install-index += $$(NL)printf "%s\n" "$3" >> $$@
install: $2

endef

define install-wildcard-target =
install-receipt += $$(NL)install -m $1 -D -t "$$(DESTDIR)$$(CFG_HOME)/$(dir $3)" $2
install-index += $$(NL)printf "%s\n" $2 | awk -v p="$(dir $3)" '{print p $$$$0}' >> $$@
install: build
endef

define install-symlink-target =
install-receipt += $$(NL)ln -sf "$1" "$$(DESTDIR)$$(CFG_HOME)/$(dir $3)$2"
install-index += $$(NL)printf "%s\n" "$(dir $3)$2" >> $$@
endef

define install-cmd-target =
install-receipt += $$(NL)$1
endef

install-path = $(INSDIR)$(subst dot.,.,$1)
install = $(eval $(call install-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-wildcard = $(eval $(call install-wildcard-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-symlink = $(eval $(call install-symlink-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-cmd=$(eval $(call install-cmd-target,$1))

install: UNINSTALL=$(DESTDIR)$(CFG_HOME)/$(UNINSTDIR)$(UNINSTNAME)
install: IDX=$(DESTDIR)$(CFG_HOME)/$(IDXDIR)$(IDXNAME)
install:
	$(MAKE) $(IDXNAME) $(UNINSTNAME)
	$(if $(wildcard $(UNINSTALL)),$(UNINSTALL))
	$(install-receipt)
	$(if $(wildcard $(IDXNAME)),install -m 00644 -D -T "$(IDXNAME)" "$(IDX)")
	$(if $(wildcard $(UNINSTNAME)),install -m 00755 -D -T "$(UNINSTNAME)" "$(UNINSTALL)")

uninstall: UNINSTALL=$(DESTDIR)$(CFG_HOME)/$(UNINSTDIR)$(UNINSTNAME)
uninstall:
	$(if $(wildcard $(UNINSTALL)),$(UNINSTALL))

