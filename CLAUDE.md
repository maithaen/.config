# CLAUDE.md - AI Assistant Context

> **Purpose**: This document provides comprehensive context for AI assistants working with this dotfiles configuration repository.

## 📋 Project Overview

This is a **personal development environment configuration repository** (dotfiles) designed for Linux/WSL environments. It provides a complete, beautiful terminal experience with custom Python CLI tools, shell configurations, and development utilities.

**Repository Location**: Flexible - can be cloned to:
- `~/.dotfiles` (recommended)
- `~/my-dotfiles` (custom location)
- `~/.config` (legacy, still supported)

**Installation Method**: The repository uses a two-script approach:
1. **`install.sh`** - Quick install wrapper that clones the repo and runs setup
2. **`setup.sh`** - Main setup script with full configuration options

**Primary Goal**: One-command setup for a fully-configured development environment with modern tools, beautiful aesthetics, and productivity-enhancing utilities.

**Key Innovation**: After cloning, the setup script automatically creates symlinks from your home directory to the dotfiles repository, allowing you to:
- Keep all configs in one git-tracked location
- Update configs by editing files in the repo
- Easily backup and sync across machines
- Clone to any location you prefer



---

## 🏗️ Architecture

### Core Components

1. **Shell Configuration** (`.zshrc`)
   - Oh My Zsh with Agnoster theme
   - Plugins: git, zsh-autosuggestions, zsh-syntax-highlighting
   - Custom aliases and functions
   - FZF fuzzy finder integration

2. **Python CLI Tools** (`pycli/`)
   - `orun.py` - Ollama Run CLI for AI model interaction
   - `devinit.py` - Development configuration file generator
   - `devutils.py` - System utilities and development helpers
   - `setup_pycli.py` - UV-based setup script

3. **Terminal Configuration**
   - Alacritty terminal emulator config (`alacritty/alacritty.yml`)
   - Tmux multiplexer config (`tmux/tmux.conf`)

4. **PowerShell Scripts** (`powershell/`)
   - Windows PowerShell profile and utilities
   - File initialization and function aliases

5. **Setup Automation**
   - `setup.sh` - One-command Linux/WSL setup script

---

## 🐍 Python CLI Tools Deep Dive

### 1. orun.py - Ollama Run CLI

**Purpose**: Beautiful CLI for interacting with Ollama AI models with streaming markdown output.

**Key Features**:
- Streaming responses with Rich markdown rendering
- Model selection via `-md` flag
- System role configuration
- Clean, formatted output

**Usage Examples**:
```bash
orun "how to create a git branch"
orun "explain python decorators" -md=mistral:latest
orun "write hello world in rust" > hello.rs
```

**Dependencies**: `rich`, `requests`

---

### 2. devinit.py - Configuration File Generator

**Purpose**: Generate configuration files for various development tools and project types.

**Available Templates** (18 total):
- **Linters/Formatters**: `golangci`, `eslint`, `prettier`, `flake8`
- **Build Tools**: `pyproject`, `typescript`, `cargo`, `makefile`
- **Containerization**: `dockerfile`, `dockerignore`
- **Version Control**: `gitignore`, `gitattributes`
- **Editor Config**: `editorconfig`, `vscode`
- **AI Tools**: `aider`
- **Testing**: `jest`
- **CI/CD**: `github-actions`

**Project Type Presets**:
- `python` - Python project configs (gitignore, pyproject, flake8, aider, etc.)
- `node` - Node.js project configs (gitignore, eslint, prettier, typescript, etc.)
- `go` - Go project configs (gitignore, golangci, dockerfile, etc.)
- `rust` - Rust project configs (gitignore, cargo, editorconfig, etc.)
- `full` - All available templates

**Usage Examples**:
```bash
devinit --list                    # List all templates
devinit gitignore                 # Generate .gitignore
devinit pyproject                 # Generate pyproject.toml
devinit --all --type python       # Generate all Python configs
devinit --all --type node         # Generate all Node.js configs
```

**Key Functions**:
- `write_config(template_name, output_path)` - Write single config file
- `list_templates()` - Display all available templates
- `generate_all(project_type)` - Generate all configs for a project type
- `main()` - CLI entry point with argparse

**Template Structure**:
```python
TEMPLATES = {
    "template_name": {
        "filename": "output_filename",
        "description": "Template description",
        "content": """template content"""
    }
}
```

---

### 3. devutils.py - Development Utilities

**Purpose**: Collection of enhanced system utilities and development helpers.

**Available Commands**:

| Command | Description | Example |
|---------|-------------|---------|
| `which` | Find command path (Unix which) | `devutils which python` |
| `ll` | Enhanced directory listing (lsd/eza) | `devutils ll /home/user` |
| `tree` | Directory tree view | `devutils tree -L 5` |
| `sysinfo` | System information (neofetch/fastfetch) | `devutils sysinfo` |
| `open` | Open file manager | `devutils open .` |

**Key Features**:
- Rich console output with colors and formatting
- Fallback mechanisms (e.g., lsd → eza → ls)
- Cross-platform file manager detection

**Implementation Details**:
- Uses `rich` library for beautiful output
- Command existence checking before execution
- Subprocess management for external tools
- Argparse for CLI argument handling

---

## 🔧 Shell Configuration (.zshrc)

### Aliases

**System Aliases**:
```bash
vim="nvim"           # Use Neovim
cls="clear"          # Clear terminal
cat="batcat"         # Syntax highlighted cat
ls="exa --icons"     # Pretty file listing
tt="eza --icons --tree -L 2"  # Tree view
python="python3"     # Python 3 default
py="python3"         # Short Python alias
```

**Python CLI Tool Functions**:
```bash
orun()      # Ollama Run CLI
devinit()   # Config file generator
devutils()  # Utility functions
which()     # Find command path
ll()        # Enhanced directory listing
sysinfo()   # System information
open()      # Open file manager
```

### Plugins

1. **git** - Git integration and aliases
2. **zsh-autosuggestions** - Fish-like command suggestions
3. **zsh-syntax-highlighting** - Real-time syntax highlighting

### Theme

**Agnoster** - Clean, informative prompt with:
- Git status indicators
- Current directory
- User and hostname (SSH)
- Virtual environment indicators

---

## 📦 Dependencies

### System Packages

| Package | Purpose | Installation |
|---------|---------|--------------|
| `zsh` | Modern shell | `apt install zsh` |
| `git` | Version control | `apt install git` |
| `curl` | HTTP client | `apt install curl` |
| `fzf` | Fuzzy finder | `apt install fzf` |
| `tmux` | Terminal multiplexer | `apt install tmux` |
| `neovim` | Modern vim | `apt install neovim` |
| `eza/exa` | Modern ls | `apt install eza` |
| `bat` | Modern cat | `apt install bat` |
| `python3` | Python runtime | `apt install python3` |

### Python Packages

```bash
pip3 install rich requests --user
```

**Or with UV**:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
cd ~/.config/pycli && python3 setup_pycli.py
```

---

## 🚀 Setup & Installation

### Quick Setup (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/maithaen/.config/main/install.sh | bash
```
This downloads and runs `install.sh`, which clones the repo to `~/.dotfiles` and runs `setup.sh`.

### Setup Options

The `setup.sh` script supports several modes:

```bash
./setup.sh              # Full setup with all packages
./setup.sh --minimal    # Skip optional packages (alacritty, ripgrep, etc.)
./setup.sh --links-only # Only create symlinks, skip installation
./setup.sh --help       # Show help message
```

### What `setup.sh` Does

1. **Detects Linux distribution** and package manager (apt, dnf, pacman, brew)
2. **Installs system packages**:
   - Essential: zsh, git, curl, fzf, tmux, neovim, python3, python3-pip
   - Modern CLI tools: eza/exa, bat/batcat
   - Optional (unless --minimal): alacritty, ripgrep, fd-find
3. **Installs Oh My Zsh** (non-interactive mode)
4. **Installs Zsh plugins**:
   - zsh-autosuggestions
   - zsh-syntax-highlighting
5. **Creates symbolic links**:
   - `~/.zshrc` → `$DOTFILES_DIR/.zshrc`
   - `~/.tmux.conf` → `$DOTFILES_DIR/tmux/tmux.conf`
   - `~/.config/alacritty/alacritty.yml` → `$DOTFILES_DIR/alacritty/alacritty.yml`
   - `~/.config/dotfiles` → `$DOTFILES_DIR` (convenience link)
   - **Backs up existing files** before creating symlinks
6. **Sets up Python CLI tools**:
   - Makes scripts executable
   - Installs dependencies from `requirements.txt` (rich, requests)
   - Runs `setup_pycli.py` if available
7. **Changes default shell to zsh** (with user confirmation)

### What `install.sh` Does

The `install.sh` wrapper script:
1. Checks if git is installed
2. Clones the repository to `~/.dotfiles` (or uses existing directory)
3. Runs `setup.sh` from the cloned repository



---

## 📂 Directory Structure

### Repository Structure
```
~/.dotfiles/  (or wherever you clone it)
├── .zshrc                          # Zsh configuration & aliases
├── CLAUDE.md                       # This file - AI assistant context
├── README.md                       # User-facing documentation
├── install.sh                      # Quick install wrapper script
├── setup.sh                        # Main setup script (improved!)
├── alacritty/
│   └── alacritty.yml              # Terminal emulator config
├── tmux/
│   └── tmux.conf                  # Terminal multiplexer config
├── powershell/                    # Windows PowerShell configs
│   ├── Microsoft.PowerShell_profile.ps1
│   ├── files-Init.ps1
│   └── functions-alias.ps1
└── pycli/                         # Python CLI tools
    ├── orun.py                    # Ollama Run CLI
    ├── devinit.py                 # Config file generator
    ├── devutils.py                # Development utilities
    ├── setup_pycli.py             # UV-based setup script
    └── requirements.txt           # Python dependencies (NEW!)
```

### Symlinks Created After Installation
```
~/.zshrc                           → ~/.dotfiles/.zshrc
~/.tmux.conf                       → ~/.dotfiles/tmux/tmux.conf
~/.config/alacritty/alacritty.yml  → ~/.dotfiles/alacritty/alacritty.yml
~/.config/dotfiles                 → ~/.dotfiles (convenience link)
```

**Important**: The `.zshrc` file automatically detects the dotfiles directory location using the `DOTFILES_DIR` environment variable, so it works regardless of where you clone the repository.

---

## 🎯 Common Tasks for AI Assistants

### Adding a New Template to devinit.py

1. Add template to `TEMPLATES` dictionary:
```python
"template_name": {
    "filename": "output_filename",
    "description": "Template description",
    "content": """template content"""
}
```

2. Add to appropriate project type in `PROJECT_TYPES` if needed
3. Update README.md template count and list

### Adding a New Command to devutils.py

1. Create command function:
```python
def cmd_newcommand(args):
    """Description of command."""
    # Implementation
```

2. Add to `COMMANDS` dictionary in `main()`:
```python
"newcommand": cmd_newcommand
```

3. Update help text in `main()`
4. Update README.md with new command

### Adding a New Alias to .zshrc

1. For simple aliases:
```bash
alias name="command"
```

2. For functions calling Python scripts:
```bash
functionname() {
    python3 ~/.config/pycli/script.py "$@"
}
```

3. Update README.md alias table

---

## 🔍 Code Patterns & Conventions

### Python CLI Tools

**Standard Structure**:
```python
#!/usr/bin/env python3
"""
Tool Name - Brief Description

Detailed description and usage examples.
"""

import sys
import argparse
from rich.console import Console

console = Console()

# Helper functions
def print_success(message: str):
    console.print(f"[green]✓[/green] {message}")

def print_error(message: str):
    console.print(f"[red]✗[/red] {message}", style="bold red")

# Main functions
def main():
    parser = argparse.ArgumentParser(description="...")
    # Add arguments
    args = parser.parse_args()
    # Implementation

if __name__ == "__main__":
    main()
```

**Output Conventions**:
- Use Rich console for colored output
- Success: `[green]✓[/green]` prefix
- Error: `[red]✗[/red]` prefix
- Warning: `[yellow]⚠[/yellow]` prefix
- Info: `[blue]ℹ[/blue]` prefix

---

## 🐛 Troubleshooting

### Common Issues

**Zsh plugins not loading**:
```bash
ls ~/.oh-my-zsh/custom/plugins/
# Should show: zsh-autosuggestions zsh-syntax-highlighting
```

**Command not found errors**:
```bash
source ~/.zshrc
```

**Python CLI tools not working**:
```bash
pip3 install rich requests --user
chmod +x ~/.config/pycli/*.py
```

**bat/batcat alias not working**:
- Ubuntu uses `batcat` instead of `bat`
- Alias already handles this: `alias cat="batcat"`

---

## 📝 File Modification Guidelines

### When Editing devinit.py

- **Line 514** is currently in the middle of template definitions
- Templates are defined in the `TEMPLATES` dictionary (lines ~50-544)
- Project types are defined in `PROJECT_TYPES` dictionary (lines ~545-614)
- Helper functions: lines 619-644
- Main functions: lines 652-787

### When Editing devutils.py

- Command functions follow pattern: `cmd_<name>(args)`
- Each command is self-contained
- Uses `command_exists()` to check for external tools
- Falls back gracefully when tools are missing

### When Editing .zshrc

- Keep Oh My Zsh configuration at top (lines 1-78)
- User configuration starts at line 80
- Aliases start at line 105
- Python CLI functions start at line 113
- FZF setup at end (line 149)

---

## 🔗 Related Resources

- **Oh My Zsh**: https://ohmyz.sh/
- **Alacritty**: https://alacritty.org/
- **Tmux**: https://github.com/tmux/tmux
- **Rich (Python)**: https://rich.readthedocs.io/
- **UV (Python)**: https://docs.astral.sh/uv/
- **FZF**: https://github.com/junegunn/fzf
- **Eza**: https://github.com/eza-community/eza

---

## 💡 Development Philosophy

1. **One-Command Setup**: Minimize friction for new environment setup
2. **Beautiful Output**: Use Rich library for enhanced terminal aesthetics
3. **Graceful Degradation**: Fallback to alternatives when tools are missing
4. **Cross-Platform**: Support Linux, WSL, and Windows PowerShell
5. **Modular Design**: Each tool is self-contained and reusable
6. **User-Friendly**: Clear error messages and helpful documentation

---

## 🎨 Design Decisions

### Why Python for CLI Tools?

- Cross-platform compatibility (Linux, WSL, Windows)
- Rich ecosystem (Rich library for beautiful output)
- Easy to maintain and extend
- No compilation needed
- Good for text processing and system utilities

### Why Zsh over Bash?

- Better autocompletion
- Plugin ecosystem (Oh My Zsh)
- Syntax highlighting and suggestions
- More customizable prompts
- Better history management

### Why UV for Python Package Management?

- Faster than pip
- Better dependency resolution
- Project-based virtual environments
- Compatible with pip and pyproject.toml
- Modern Python tooling

---

## 📊 Statistics

- **Total Python CLI Tools**: 3 (orun, devinit, devutils)
- **Total devinit Templates**: 18
- **Total devutils Commands**: 5
- **Total Shell Aliases**: 15+
- **Supported Project Types**: 5 (python, node, go, rust, full)
- **Lines of Code**:
  - `devinit.py`: ~792 lines
  - `devutils.py`: ~423 lines
  - `.zshrc`: ~150 lines

---

## 🚦 Current Status

**Last Updated**: 2025-12-10

**Recent Changes** (Major Refactoring):
- ✨ **Added `install.sh`** - Quick install wrapper script for one-command setup
- 🔧 **Completely refactored `setup.sh`** with:
  - `--minimal` mode to skip optional packages
  - `--links-only` mode for symlink-only updates
  - Better error handling and backup functionality
  - Improved progress indicators and user feedback
  - Support for multiple package managers (apt, dnf, pacman, brew)
- 📁 **Flexible directory structure** - Can clone to `~/.dotfiles`, `~/my-dotfiles`, or `~/.config`
- 🔗 **Smart symlink management** - Automatically backs up existing files before linking
- 🐍 **Added `requirements.txt`** for Python dependencies
- 🎯 **Auto-detecting `DOTFILES_DIR`** in `.zshrc` - Works regardless of clone location
- 📝 **Updated all documentation** (README.md, CLAUDE.md) to reflect new structure
- 🚀 **Improved setup workflow** - Clearer installation options and better UX

**Previous Changes**:
- Migrated PowerShell scripts to Python CLI tools
- Added UV-based setup script
- Enhanced devutils with Android development tools
- Improved error handling and output formatting

**Known Issues**: None

**Planned Enhancements**:
- Add more devinit templates (docs templates, setup templates)
- Enhance orun with more AI model providers
- Add more devutils commands for common tasks
- Consider adding a `dotfiles` command for managing the dotfiles repo itself



---

## 🤖 AI Assistant Guidelines

When working with this repository:

1. **Respect the structure**: Keep Python tools in `pycli/`, configs in their respective directories
2. **Follow conventions**: Use Rich for output, maintain consistent error handling
3. **Update documentation**: Modify both README.md and CLAUDE.md when adding features
4. **Test cross-platform**: Consider Linux, WSL, and Windows compatibility
5. **Maintain backwards compatibility**: Don't break existing aliases or commands
6. **Use type hints**: Python functions should have type annotations
7. **Add docstrings**: Document all functions and modules
8. **Handle errors gracefully**: Check for missing dependencies, provide helpful messages

---

**End of AI Assistant Context Document**
