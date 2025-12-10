#!/bin/bash

# ============================================================================
# Dotfiles Setup Script - Complete Development Environment Setup
# ============================================================================
# This script sets up a complete development environment on Linux/WSL
# 
# Usage:
#   ./setup.sh              # Full setup
#   ./setup.sh --minimal    # Skip optional packages
#   ./setup.sh --links-only # Only create symlinks
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

# Determine script directory (where this script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR"

# Parse arguments
MINIMAL_INSTALL=false
LINKS_ONLY=false

for arg in "$@"; do
    case $arg in
        --minimal)
            MINIMAL_INSTALL=true
            shift
            ;;
        --links-only)
            LINKS_ONLY=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --minimal      Skip optional packages (alacritty, etc.)"
            echo "  --links-only   Only create symbolic links, skip installation"
            echo "  --help, -h     Show this help message"
            exit 0
            ;;
    esac
done

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
# Package Manager Detection & Installation
# ============================================================================

detect_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

install_packages() {
    local pkg_manager=$(detect_package_manager)
    
    print_info "Detected package manager: $pkg_manager"
    
    case $pkg_manager in
        apt)
            print_info "Updating package lists..."
            sudo apt update
            print_info "Installing essential packages..."
            sudo apt install -y git curl zsh fzf tmux neovim python3 python3-pip
            
            # Install modern CLI tools
            print_info "Installing modern CLI replacements..."
            sudo apt install -y exa 2>/dev/null || sudo apt install -y eza 2>/dev/null || print_warning "exa/eza not available"
            sudo apt install -y bat 2>/dev/null || sudo apt install -y batcat 2>/dev/null || print_warning "bat not available"
            
            # Optional packages
            if [ "$MINIMAL_INSTALL" = false ]; then
                print_info "Installing optional packages..."
                sudo apt install -y alacritty 2>/dev/null || print_warning "alacritty not in default repos (optional)"
                sudo apt install -y ripgrep fd-find 2>/dev/null || print_warning "ripgrep/fd-find not available (optional)"
            fi
            ;;
        dnf)
            print_info "Installing packages..."
            sudo dnf install -y git curl zsh eza bat fzf tmux neovim python3 python3-pip
            if [ "$MINIMAL_INSTALL" = false ]; then
                sudo dnf install -y alacritty ripgrep fd-find 2>/dev/null || true
            fi
            ;;
        yum)
            print_info "Installing packages..."
            sudo yum install -y git curl zsh fzf tmux neovim python3 python3-pip
            ;;
        pacman)
            print_info "Installing packages..."
            sudo pacman -S --needed --noconfirm git curl zsh eza bat fzf tmux neovim python python-pip
            if [ "$MINIMAL_INSTALL" = false ]; then
                sudo pacman -S --needed --noconfirm alacritty ripgrep fd 2>/dev/null || true
            fi
            ;;
        brew)
            print_info "Installing packages..."
            brew install git curl zsh eza bat fzf tmux neovim python3
            if [ "$MINIMAL_INSTALL" = false ]; then
                brew install alacritty ripgrep fd 2>/dev/null || true
            fi
            ;;
        *)
            print_error "Unsupported package manager. Please install packages manually:"
            echo "  Required: git curl zsh fzf tmux neovim python3 python3-pip"
            echo "  Optional: eza/exa bat alacritty ripgrep fd-find"
            return 1
            ;;
    esac
    
    print_status "Packages installed successfully"
}

# ============================================================================
# Oh My Zsh Setup
# ============================================================================

setup_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_info "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        print_status "Oh My Zsh installed"
    else
        print_warning "Oh My Zsh is already installed"
    fi
}

# ============================================================================
# Zsh Plugins Setup
# ============================================================================

setup_zsh_plugins() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # zsh-autosuggestions
    if [ ! -d "$plugin_dir/zsh-autosuggestions" ]; then
        print_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir/zsh-autosuggestions"
        print_status "zsh-autosuggestions installed"
    else
        print_warning "zsh-autosuggestions already installed"
    fi
    
    # zsh-syntax-highlighting
    if [ ! -d "$plugin_dir/zsh-syntax-highlighting" ]; then
        print_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir/zsh-syntax-highlighting"
        print_status "zsh-syntax-highlighting installed"
    else
        print_warning "zsh-syntax-highlighting already installed"
    fi
}

# ============================================================================
# Create Symbolic Links
# ============================================================================

create_symlinks() {
    print_info "Creating symbolic links from $DOTFILES_DIR..."
    
    # Backup function
    backup_if_exists() {
        if [ -e "$1" ] && [ ! -L "$1" ]; then
            local backup_name="$1.backup.$(date +%Y%m%d_%H%M%S)"
            print_warning "Backing up existing $1 to $backup_name"
            mv "$1" "$backup_name"
        elif [ -L "$1" ]; then
            # Remove existing symlink
            rm "$1"
        fi
    }
    
    # Zsh configuration
    print_info "Linking .zshrc..."
    backup_if_exists "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    print_status "Linked .zshrc → ~/.zshrc"
    
    # Tmux configuration
    if [ -f "$DOTFILES_DIR/tmux/tmux.conf" ]; then
        print_info "Linking tmux.conf..."
        backup_if_exists "$HOME/.tmux.conf"
        ln -sf "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
        print_status "Linked tmux.conf → ~/.tmux.conf"
    fi
    
    # Alacritty configuration
    if [ -f "$DOTFILES_DIR/alacritty/alacritty.yml" ]; then
        print_info "Linking alacritty.yml..."
        mkdir -p "$HOME/.config/alacritty"
        backup_if_exists "$HOME/.config/alacritty/alacritty.yml"
        ln -sf "$DOTFILES_DIR/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
        print_status "Linked alacritty.yml → ~/.config/alacritty/alacritty.yml"
    fi
    
    # Create .config symlink for easy access
    if [ ! -L "$HOME/.config/dotfiles" ]; then
        print_info "Creating convenience symlink..."
        ln -sf "$DOTFILES_DIR" "$HOME/.config/dotfiles"
        print_status "Linked $DOTFILES_DIR → ~/.config/dotfiles"
    fi
    
    print_status "All symbolic links created successfully"
}

# ============================================================================
# Python CLI Tools Setup
# ============================================================================

setup_pycli() {
    if [ -d "$DOTFILES_DIR/pycli" ]; then
        print_info "Setting up Python CLI tools..."
        
        # Make scripts executable
        chmod +x "$DOTFILES_DIR/pycli/"*.py 2>/dev/null || true
        print_status "Made Python scripts executable"
        
        # Install Python dependencies
        if [ -f "$DOTFILES_DIR/pycli/requirements.txt" ]; then
            print_info "Installing Python dependencies..."
            pip3 install -r "$DOTFILES_DIR/pycli/requirements.txt" --user --quiet 2>/dev/null || {
                print_warning "Failed to install from requirements.txt, trying individual packages..."
                pip3 install rich requests --user --quiet 2>/dev/null || print_warning "Some Python packages may not be installed"
            }
            print_status "Python dependencies installed"
        else
            print_info "Installing common Python dependencies..."
            pip3 install rich requests --user --quiet 2>/dev/null || print_warning "Some Python packages may not be installed"
        fi
        
        # Run pycli setup script if it exists
        if [ -f "$DOTFILES_DIR/pycli/setup_pycli.py" ]; then
            print_info "Running pycli setup script..."
            python3 "$DOTFILES_DIR/pycli/setup_pycli.py" 2>/dev/null || print_warning "pycli setup script encountered issues (non-critical)"
        fi
        
        print_status "Python CLI tools configured"
    else
        print_warning "pycli directory not found, skipping Python CLI setup"
    fi
}

# ============================================================================
# Change Default Shell
# ============================================================================

change_shell() {
    local zsh_path=$(which zsh)
    
    if [ "$SHELL" != "$zsh_path" ]; then
        print_info "Changing default shell to zsh..."
        if chsh -s "$zsh_path" 2>/dev/null; then
            print_status "Default shell changed to zsh"
            print_warning "Please log out and log back in for shell change to take effect"
        else
            print_warning "Could not change shell automatically. Run manually: chsh -s $zsh_path"
        fi
    else
        print_status "Zsh is already the default shell"
    fi
}

# ============================================================================
# Print Summary
# ============================================================================

print_summary() {
    print_header "Setup Complete! 🚀"
    
    echo -e "${GREEN}${BOLD}What was installed:${NC}"
    echo "  ✓ Oh My Zsh with plugins (autosuggestions, syntax-highlighting)"
    echo "  ✓ Development tools (git, curl, fzf, tmux, neovim)"
    echo "  ✓ Modern CLI replacements (eza, bat)"
    echo "  ✓ Python CLI tools (orun, devinit, devutils)"
    echo ""
    echo -e "${CYAN}${BOLD}Configuration files linked:${NC}"
    echo "  • ~/.zshrc → $DOTFILES_DIR/.zshrc"
    echo "  • ~/.tmux.conf → $DOTFILES_DIR/tmux/tmux.conf"
    echo "  • ~/.config/alacritty/alacritty.yml → $DOTFILES_DIR/alacritty/alacritty.yml"
    echo "  • ~/.config/dotfiles → $DOTFILES_DIR (convenience link)"
    echo ""
    echo -e "${CYAN}${BOLD}Available commands:${NC}"
    echo "  ${GREEN}Shell Aliases:${NC}"
    echo "    vim, cls, cat, ls, tt, py"
    echo ""
    echo "  ${GREEN}Python CLI Tools:${NC}"
    echo "    orun      - Ollama Run CLI for AI models"
    echo "    devinit   - Generate config files (gitignore, eslint, etc.)"
    echo "    devutils  - Development utilities (which, ll, tree, sysinfo, etc.)"
    echo ""
    echo -e "${YELLOW}${BOLD}Next steps:${NC}"
    echo "  1. Restart your terminal or run: ${CYAN}source ~/.zshrc${NC}"
    echo "  2. Log out and log back in to use zsh as default shell"
    echo "  3. Try: ${CYAN}devinit --list${NC} to see available config templates"
    echo "  4. Try: ${CYAN}ll${NC} for enhanced directory listing"
    echo ""
    echo -e "${BOLD}${GREEN}Enjoy your beautiful terminal! ✨${NC}"
    echo ""
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    print_header "Dotfiles Setup - Complete Development Environment"
    
    echo -e "${CYAN}Dotfiles directory: ${BOLD}$DOTFILES_DIR${NC}"
    echo ""
    
    if [ "$LINKS_ONLY" = true ]; then
        echo -e "${YELLOW}Running in links-only mode${NC}"
        echo ""
        print_header "Creating Symbolic Links"
        create_symlinks
        print_status "Symbolic links created. Run 'source ~/.zshrc' to apply changes."
        exit 0
    fi
    
    echo -e "${CYAN}This script will:${NC}"
    echo "  1. Install required packages"
    echo "  2. Install Oh My Zsh + plugins"
    echo "  3. Create symbolic links for config files"
    echo "  4. Setup Python CLI tools"
    echo "  5. Change default shell to zsh"
    echo ""
    
    if [ "$MINIMAL_INSTALL" = true ]; then
        echo -e "${YELLOW}Running in minimal mode (skipping optional packages)${NC}"
        echo ""
    fi
    
    # Ask for confirmation unless running non-interactively
    if [ -t 0 ]; then
        read -p "Continue? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ -n $REPLY ]]; then
            print_error "Setup cancelled"
            exit 1
        fi
    fi
    
    # Run setup steps
    print_header "Step 1: Installing Packages"
    install_packages
    
    print_header "Step 2: Installing Oh My Zsh"
    setup_oh_my_zsh
    
    print_header "Step 3: Installing Zsh Plugins"
    setup_zsh_plugins
    
    print_header "Step 4: Creating Symbolic Links"
    create_symlinks
    
    print_header "Step 5: Setting Up Python CLI Tools"
    setup_pycli
    
    print_header "Step 6: Configuring Shell"
    change_shell
    
    # Print summary
    print_summary
}

# ============================================================================
# Run Script
# ============================================================================

# Allow running specific functions if passed as argument
if [ "$1" = "install_packages" ] || [ "$1" = "create_symlinks" ] || [ "$1" = "setup_pycli" ]; then
    "$@"
else
    main
fi