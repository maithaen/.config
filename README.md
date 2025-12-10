
# Dotfiles Configuration

This repository contains personal configuration files for various tools and shells. Here's how to set them up on a new Linux system.

## Quick Setup (One-liner)

```bash
git clone https://github.com/maithaen/.config.git ~/.config && cd ~/.config && chmod +x setup.sh && ./setup.sh
```

## Manual Setup

### Prerequisites

Install required packages:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git curl zsh exa bat fzf tmux alacritty

# Fedora/RHEL
sudo dnf install -y git curl zsh exa bat fzf tmux alacritty

# Arch Linux
sudo pacman -S git curl zsh exa bat fzf tmux alacritty
```

### Zsh Setup

1. Install Oh My Zsh:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

2. Install Zsh Plugins:
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

3. Link Zsh configuration:
```bash
ln -sf ~/.config/.zshrc ~/.zshrc
```

4. Set Zsh as default shell:
```bash
chsh -s $(which zsh)
```

### Application Configurations

#### Alacritty Terminal
```bash
# Create config directory if it doesn't exist
mkdir -p ~/.config/alacritty

# Link configuration
ln -sf ~/.config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
```

#### Tmux
```bash
# Link tmux configuration
ln -sf ~/.config/tmux/tmux.conf ~/.tmux.conf
```

#### PowerShell (for Windows/WSL users)
```bash
# Create PowerShell config directory
mkdir -p ~/.config/powershell

# Link PowerShell profiles
ln -sf ~/.config/powershell/Microsoft.PowerShell_profile.ps1 ~/.config/powershell/Microsoft.PowerShell_profile.ps1
ln -sf ~/.config/powershell/files-Init.ps1 ~/.config/powershell/files-Init.ps1
ln -sf ~/.config/powershell/functions-alias.ps1 ~/.config/powershell/functions-alias.ps1
```

#### Python CLI Tools
```bash
# Add pycli to PATH (add to your shell profile)
echo 'export PATH="$HOME/.config/pycli:$PATH"' >> ~/.zshrc
```

## Post-Setup

1. Reload your shell:
```bash
source ~/.zshrc
```

2. Verify installations:
```bash
# Check Zsh version
zsh --version

# Check Oh My Zsh
echo $ZSH

# Check plugins
ls ~/.oh-my-zsh/custom/plugins/
```

## Features

- **Zsh**: Enhanced with Oh My Zsh, autosuggestions, and syntax highlighting
- **Aliases**: Convenient aliases for common commands (vim→nvim, cls→clear, cat→batcat, ls→exa)
- **Alacritty**: Modern GPU-accelerated terminal emulator configuration
- **Tmux**: Terminal multiplexer configuration
- **PowerShell**: Cross-platform PowerShell profiles
- **Python CLI**: Custom Python scripts for command-line productivity

## Customization

Feel free to modify any configuration files to suit your preferences. The most commonly edited files are:

- `~/.zshrc` - Shell configuration and aliases
- `~/.config/alacritty/alacritty.yml` - Terminal appearance and behavior
- `~/.config/tmux/tmux.conf` - Terminal multiplexer settings

## Troubleshooting

If you encounter issues:

1. Make sure all dependencies are installed
2. Check file permissions: `chmod +x ~/.config/setup.sh`
3. Verify symbolic links: `ls -la ~/.config`
4. Restart your terminal after making changes

## Contributing

Suggestions and improvements are welcome! Please open an issue or submit a pull request.
