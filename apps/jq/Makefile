include ../../common.mk

.PHONY: clean
clean:
	$(RM) jq

jq:
	curl -fsSL "https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64" -o "$@"
	chmod +x "$@"

.PHONY: build
build: jq

$(call install,00755,jq,.local/bin/jq)

$(call update-simple)
