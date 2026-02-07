.PHONY: default
default: build

.PHONY: build install clean uninstall update

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

M4CONFIG = $(PRJROOT)config.m4
M4=m4 -P $(M4CONFIG)
M4CONFIG_DATA=m4_divert(-1)
M4CONFIG_DATA+=$(file < $(TOOLS)base.m4)
M4CONFIG_DATA+=$(foreach v,$(filter CFG_%, $(.VARIABLES)),$(if $($v),$(NL)m4_define(<[M4_$v]>,<[$($v)]>)))
M4CONFIG_DATA+=$(NL)m4_divert(0)m4_dnl
$(M4CONFIG): $(CONFIG)
	@echo "Writing $@"
	$(file >$@,$(M4CONFIG_DATA))
	sed -i -e 's/\s*$$//' "$@"

.PHONY: $(M4CONFIG)-clean
clean: $(M4CONFIG)-clean
$(M4CONFIG)-clean:
	$(RM) "$(M4CONFIG)"

define m4-target =
.PHONY: $1-clean
$1: $1.in $$(M4CONFIG)
	$$(M4) $2 "$1.in" > "$$@"

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

.PHONY: $1-clean
clean: $1-clean
$1-clean:
	$$(RM) $$(fake-$1)

endef
fake = $(eval $(call fake-target,$1))

define subdir-target =
.PHONY: $1-build $1-install $1-clean $1-uninstall $1-update
$1-build:
	$$(MAKE) -C "$1" build

$1-install:
	$$(MAKE) -C "$1" install

$1-uninstall:
	$$(MAKE) -C "$1" uninstall

$1-clean:
	$$(MAKE) -C "$1" clean

$1-update:
	$$(MAKE) -C "$1" update

install: $1-install
build: $1-build
clean: $1-clean
uninstall: $1-uninstall
update: $1-update
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

.PHONY: $(IDXNAME)-install
$(IDXNAME)-install: $(IDXNAME)
	$(if $(wildcard $(IDXNAME)),install -m 00644 -D -T "$(IDXNAME)" "$(DESTDIR)$(CFG_HOME)/$(IDXDIR)$(IDXNAME)")

UNINSTDIR = .local/lib/home/uninstall/
UNINSTCD = ../../../../
UNINSTNAME = $(subst /,-,$(SUBDIR)uninstall.sh)

define uninstall-sh =
#!/bin/bash
cd "$$(dirname "$$(realpath "$${BASH_SOURCE[0]}")")"/$(UNINSTCD) || exit 1
while IFS= read -r file; do
	rm -vf "$$file"
	dir=$$(dirname "$$file")
	[[ $$dir = [./] ]] || rmdir -p --ignore-fail-on-non-empty "$$dir"
done < "$(IDXDIR)$(IDXNAME)"
rm -vf "$(IDXDIR)$(IDXNAME)"
rmdir -p --ignore-fail-on-non-empty "$(IDXDIR)"
rm -vf "$(UNINSTDIR)$(UNINSTNAME)"
rmdir -p --ignore-fail-on-non-empty "$(UNINSTDIR)"
endef

$(UNINSTNAME):: $(IDXNAME)
	$(if $(wildcard $(IDXNAME)),@echo "Writing $@")
	$(if $(wildcard $(IDXNAME)),$(file >$@,$(uninstall-sh)))

.PHONY: $(UNINSTNAME)-clean
clean: $(UNINSTNAME)-clean
$(UNINSTNAME)-clean:
	rm -f "$(UNINSTNAME)"

.PHONY: $(UNINSTNAME)-install
$(UNINSTNAME)-install: $(UNINSTNAME)
	$(if $(wildcard $(UNINSTNAME)),install -m 00755 -D -T "$(UNINSTNAME)" "$(DESTDIR)$(CFG_HOME)/$(UNINSTDIR)$(UNINSTNAME)")


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

define install-dir-target =
install-receipt += $$(NL)mkdir -vp "$$(DESTDIR)$$(CFG_HOME)/$2"
install-receipt += $$(NL)cp -vrf "$1/." "$$(DESTDIR)$$(CFG_HOME)/$2"
install-index += $$(NL)( cd "$1" && find . -not -type d -printf "$2/%p\n" | sed -e s,/./,/, ) >> $$@
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
install-dir = $(eval $(call install-dir-target,$1,$(if $2,$2,$(call install-path,$1))))
install-wildcard = $(eval $(call install-wildcard-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-symlink = $(eval $(call install-symlink-target,$1,$2,$(if $3,$3,$(call install-path,$2))))
install-cmd=$(eval $(call install-cmd-target,$1))

install: UNINSTALL=$(DESTDIR)$(CFG_HOME)/$(UNINSTDIR)$(UNINSTNAME)
install:
	$(if $(wildcard $(UNINSTALL)),$(UNINSTALL))
	$(install-receipt)
	$(MAKE) $(IDXNAME)-install $(UNINSTNAME)-install

uninstall: UNINSTALL=$(DESTDIR)$(CFG_HOME)/$(UNINSTDIR)$(UNINSTNAME)
uninstall:
	$(if $(wildcard $(UNINSTALL)),$(UNINSTALL))

define update-simple-target =
.PHONY: update-simple
update-simple:
	$$(MAKE) clean
	$$(MAKE) build
	$$(MAKE) install

update: update-simple
endef

update-simple = $(eval $(call update-simple-target))
