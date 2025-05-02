.PHONY: default
default: build

.PHONY: build install clean

PRJROOT = $(dir $(lastword $(MAKEFILE_LIST)))
TOOLS = $(PRJROOT)tools/
CONFIG = $(PRJROOT)config.mk

include $(CONFIG)
$(CONFIG):
	$(TOOLS)makeconf.sh "$(OS)" "$(OSID)" "$(HOMEDIR)" > "$@"

M4=m4 -P -D"m4_OS=$(OS)" -D"m4_OSID=$(OSID)" -D"m4_HOMEDIR=$(HOMEDIR)"
ifneq ($(origin WSL), undefined)
	M4 += -Dm4_WSL
endif

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

subdir = $(eval $(call subdir-target,$1))
m4 = $(eval $(call m4-target,$1,$2))
find = $(wildcard $1/$2) $(foreach d,$(wildcard $(1:=/*/)),$(call find,$(d:/=),$2))
uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))
