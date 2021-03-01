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


# ------------------------------------------------------------------------------
# Escriptize
# ------------------------------------------------------------------------------

.PHONY: escriptize
escriptize: $(REBAR)
	@$(REBAR) escriptize


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
	@rm -rf _build
	@rm ./$(REBAR)
