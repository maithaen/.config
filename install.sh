#!/bin/bash

# ============================================================================
# Quick Install Script - Dotfiles Setup
# ============================================================================
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/maithaen/Dotfiles/main/install.sh | bash
#   OR
#   git clone https://github.com/maithaen/Dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./install.sh
# ============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_REPO="https://github.com/maithaen/Dotfiles.git"

# ============================================================================
# Helper Functions
# ============================================================================

print_header() {
    echo -e "\n${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[→]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Clone or Update Dotfiles
# ============================================================================

setup_dotfiles_repo() {
    # If script is already in a git repo, use that directory
    if [ -d "$SCRIPT_DIR/.git" ]; then
        DOTFILES_DIR="$SCRIPT_DIR"
        print_info "Using existing dotfiles directory: $DOTFILES_DIR"
        cd "$DOTFILES_DIR"
        git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
        print_status "Dotfiles updated"
    else
        # Clone the repository
        if [ ! -d "$DOTFILES_DIR" ]; then
            print_info "Cloning dotfiles to $DOTFILES_DIR..."
            git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
            print_status "Dotfiles cloned successfully"
        else
            print_info "Dotfiles directory exists, updating..."
            cd "$DOTFILES_DIR"
            git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
            print_status "Dotfiles updated"
        fi
    fi
}

# ============================================================================
# Run Main Setup Script
# ============================================================================

run_setup() {
    cd "$DOTFILES_DIR"
    
    if [ -f "./setup.sh" ]; then
        print_info "Running main setup script..."
        bash ./setup.sh
    else
        print_error "setup.sh not found in $DOTFILES_DIR"
        exit 1
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_header "Dotfiles Quick Install"
    
    # Check for git
    if ! command_exists git; then
        print_error "Git is not installed. Please install git first:"
        echo "  Ubuntu/Debian: sudo apt install git"
        echo "  Fedora: sudo dnf install git"
        echo "  Arch: sudo pacman -S git"
        exit 1
    fi
    
    # Setup dotfiles repository
    setup_dotfiles_repo
    
    # Run the main setup script
    run_setup
}

main "$@"
