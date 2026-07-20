# keyboard-layout — toggle UK (gb) <-> UK International (gb-intl).
# The Makefile is just a thin, memorable front door for bin/keyboard-layout.

BIN := bin/keyboard-layout

.PHONY: gb intl toggle status help install

gb:      ## Switch to the standard UK layout
	@$(BIN) gb

intl:    ## Switch to the UK International layout
	@$(BIN) intl

toggle:  ## Detect the current layout and switch to the other one
	@$(BIN) toggle

status:  ## Print the current keyboard layout
	@$(BIN) status

install: ## Symlink the script into ~/.local/bin
	@mkdir -p $(HOME)/.local/bin
	@ln -sf $(CURDIR)/$(BIN) $(HOME)/.local/bin/keyboard-layout
	@echo "Linked keyboard-layout into ~/.local/bin (ensure it's on your PATH)."

help:    ## Show available targets
	@grep -E '^[a-z]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  make %-8s %s\n", $$1, $$2}'
