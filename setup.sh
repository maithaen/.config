#!/bin/bash

# Dotfiles Setup Script
# This script sets up the dotfiles configuration on a new Linux system

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect package manager
detect_package_manager() {
    if command_exists apt; then
        echo "apt"
    elif command_exists dnf; then
        echo "dnf"
    elif command_exists yum; then
        echo "yum"
    elif command_exists pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Install packages based on package manager
install_packages() {
    local pkg_manager=$(detect_package_manager)
    
    print_status "Detected package manager: $pkg_manager"
    
    case $pkg_manager in
        apt)
            sudo apt update && sudo apt install -y git curl zsh exa bat fzf tmux alacritty
            ;;
        dnf|yum)
            sudo $pkg_manager install -y git curl zsh exa bat fzf tmux alacritty
            ;;
        pacman)
            sudo pacman -S --needed git curl zsh exa bat fzf tmux alacritty
            ;;
        *)
            print_error "Unsupported package manager. Please install packages manually."
            exit 1
            ;;
    esac
}

# Setup Oh My Zsh
setup_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_warning "Oh My Zsh is already installed"
    fi
}

# Setup Zsh plugins
setup_zsh_plugins() {
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    if [ ! -d "$plugin_dir/zsh-autosuggestions" ]; then
        print_status "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir/zsh-autosuggestions"
    else
        print_warning "zsh-autosuggestions is already installed"
    fi
    
    if [ ! -d "$plugin_dir/zsh-syntax-highlighting" ]; then
        print_status "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir/zsh-syntax-highlighting"
    else
        print_warning "zsh-syntax-highlighting is already installed"
    fi
}

# Create symbolic links
create_symlinks() {
    print_status "Creating symbolic links..."
    
    # Zsh configuration
    ln -sf "$HOME/.config/.zshrc" "$HOME/.zshrc"
    
    # Alacritty configuration
    mkdir -p "$HOME/.config/alacritty"
    ln -sf "$HOME/.config/alacritty/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
    
    # Tmux configuration
    ln -sf "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
    
    # PowerShell configuration (for Windows/WSL users)
    mkdir -p "$HOME/.config/powershell"
    ln -sf "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1" "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
    ln -sf "$HOME/.config/powershell/files-Init.ps1" "$HOME/.config/powershell/files-Init.ps1"
    ln -sf "$HOME/.config/powershell/functions-alias.ps1" "$HOME/.config/powershell/functions-alias.ps1"
    
    print_status "Symbolic links created successfully"
}

# Change default shell to zsh
change_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_status "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        print_status "Default shell changed to zsh. Please log out and log back in to apply changes."
    else
        print_warning "Zsh is already the default shell"
    fi
}

# Main setup function
main() {
    print_status "Starting dotfiles setup..."
    
    # Install required packages
    print_status "Installing required packages..."
    install_packages
    
    # Setup Oh My Zsh
    setup_oh_my_zsh
    
    # Setup Zsh plugins
    setup_zsh_plugins
    
    # Create symbolic links
    create_symlinks
    
    # Change default shell
    change_shell
    
    print_status "Setup completed successfully!"
    print_status "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

# Run main function
main "$@"