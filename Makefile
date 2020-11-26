# ------------------------------------------------------------------------------
# CauDEr Make instructions
# ------------------------------------------------------------------------------

.PHONY: default
default: escriptize


# ------------------------------------------------------------------------------
# Rebar
# ------------------------------------------------------------------------------

REBAR=$(shell which rebar3 || echo "./rebar3")
REBAR_URL="https://s3.amazonaws.com/rebar3/rebar3"

./$(REBAR):
	@echo "@echo off\nescript.exe \"%~dpn0\" %*" > rebar3.cmd
	@wget $(REBAR_URL) && chmod +x rebar3


# ------------------------------------------------------------------------------
# Compile
# ------------------------------------------------------------------------------

.PHONY: compile
compile: $(REBAR)
	@$(REBAR) compile
	@cp -rf _build/default/lib/cauder/ebin .


# ------------------------------------------------------------------------------
# Escriptize
# ------------------------------------------------------------------------------

.PHONY: escriptize
escriptize: $(REBAR)
	@$(REBAR) escriptize
	@cp -rf _build/default/bin .


# ------------------------------------------------------------------------------
# Common Test
# ------------------------------------------------------------------------------

.PHONY: ct
ct: $(REBAR)
	@$(REBAR) ct


# ------------------------------------------------------------------------------
# Edoc
# ------------------------------------------------------------------------------

.PHONY: edoc
edoc: $(REBAR)
	@$(REBAR) edoc


# ------------------------------------------------------------------------------
# Dialyzer
# ------------------------------------------------------------------------------

.PHONY: dialyzer
dialyzer: $(REBAR)
	@$(REBAR) dialyzer


# ------------------------------------------------------------------------------
# Eunit
# ------------------------------------------------------------------------------

.PHONY: eunit
eunit: $(REBAR)
	@$(REBAR) eunit


# ------------------------------------------------------------------------------
# Clean
# ------------------------------------------------------------------------------

.PHONY: clean
clean: $(REBAR)
	@$(REBAR) clean --all

.PHONY: distclean
distclean:
	@rm -rf bin
	@rm -rf ebin
	@rm -rf _build
	@rm ./$(REBAR)
