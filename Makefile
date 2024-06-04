# Define default target
.DEFAULT_GOAL := help

# Detect the OS
OS := $(shell uname -s)
WSL_VERSION := $(shell uname -sr | grep -o 'microsoft-standard-WSL2')

# Detect Debian/Ubuntu
ifeq ($(OS), Linux)
    DETECTED_OS := linux
    LINUX_DISTRIB := $(shell lsb_release -is 2>/dev/null || echo Unknown)
    ifeq ($(filter $(LINUX_DISTRIB), Ubuntu Debian), Ubuntu Debian)
        OS_TYPE := debian
    endif
endif

# Detect WSL2
ifneq ($(WSL_VERSION),)
    DETECTED_OS := wsl
endif

# Define the Neovim version
VERSION ?= stable

# Help target
help:
	@echo "Makefile for multi-OS environment"
	@echo "Usage: make [target] [VERSION=<version>]"
	@echo ""
	@echo "Targets:"
	@echo "  install-deps    Install dependencies"
	@echo "  bootstrap-env   Setting up some tools (k8s related)"
	@echo "  dotfiles   	 Setting up dotfiles"
	@echo "  all   	 		 Full setup"
	@echo "  nix   	 		 Install Nix"
	@echo "  clean           Clean the project"
	@echo "  clean-nix       Remove Nix"
	@echo "  help            Show this help message"
	@echo ""
	@echo "VERSION options:"
	@echo "  master          Latest Neovim development version"
	@echo "  stable          Latest Neovim stable version (e.g., v0.10.0)"

# Default install dependencies target
install-deps: install-deps-$(DETECTED_OS) 

# Debian/Ubuntu targets
install-deps-debian:
	@echo "Installing dependencies for Debian/Ubuntu..."
	bash ./scripts/install-deps.sh $(VERSION)

# WSL targets
install-deps-wsl:
	@echo "Installing dependencies for WSL..."
	bash ./scripts/install-deps.sh --no-gui $(VERSION)

bootstrap-env:
	@echo "Running bootstrap-env.sh script..."
	bash ./scripts/bootstrap-env.sh

dotfiles:
	@echo "Setting up dotfiles..."
	bash ./scripts/links.sh

# All target for full setup
all: all-$(DETECTED_OS)

# Full setup for Debian/Ubuntu
all-debian: install-deps-debian bootstrap-env dotfiles

# Full setup for WSL
all-wsl: install-deps-wsl bootstrap-env dotfiles

# Default clean target
clean: clean-$(DETECTED_OS)

# Nix targets
nix:
	@echo "Installing Nix..."
	@if ! command -v nix &> /dev/null; then \
	    echo "Nix not found, installing..."; \
	    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; \
	else \
	    echo "Nix is already installed."; \
	fi

clean-nix:
	@echo "Cleaning project on Nix..."
	@if command -v nix &> /dev/null; then \
	    echo "Uninstalling Nix..."; \
	    /nix/nix-installer uninstall; \
	else \
	    echo "Nix is not installed."; \
	fi
