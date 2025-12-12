# 🚀 Dotfiles Configuration

Personal development environment configuration for Linux/WSL. One command to set up a complete, beautiful terminal experience.

## ⚡ Quick Setup (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/maithaen/Dotfiles/main/install.sh | bash
```

> ⚠️ Always review scripts before running with `curl | bash`

### Setup Options

```bash
./setup.sh              # Full setup with all packages
./setup.sh --minimal    # Skip optional packages (alacritty, ripgrep, etc.)
./setup.sh --links-only # Only create symlinks, skip installation
```

---

## 📦 What Gets Installed

### Packages
| Package | Description |
|---------|-------------|
| `zsh` | Modern shell with Oh My Zsh |
| `git` | Version control |
| `curl` | HTTP client |
| `fzf` | Fuzzy finder |
| `tmux` | Terminal multiplexer |
| `neovim` | Modern vim |
| `eza/exa` | Modern `ls` replacement |
| `bat` | Modern `cat` replacement |
| `python3` | Python runtime |

### Zsh Plugins
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting in terminal

### Configuration Files
- `.zshrc` → Shell configuration & aliases
- `alacritty/alacritty.yml` → Terminal emulator config
- `tmux/tmux.conf` → Terminal multiplexer config
- `pycli/` → Custom Python CLI tools

---

## 🎨 Included Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `vim` | `nvim` | Use Neovim as default |
| `cls` | `clear` | Clear terminal |
| `cat` | `batcat` | Syntax highlighted cat |
| `ls` | `exa --icons` | Pretty file listing |
| `tt` | `eza --icons --tree -L 2` | Tree view |
| `py` | `python3` | Short Python alias |
| `orun` | `orun.py` | Ollama Run CLI |
| `devinit` | `devinit.py` | Generate config files |
| `devutils` | `devutils.py` | Dev utility functions |
| `which` | `devutils which` | Find command path |
| `ll` | `devutils ll` | Enhanced directory listing |
| `sysinfo` | `devutils sysinfo` | System information |
| `open` | `devutils open` | Open file manager |


---

## 🛠️ Manual Setup

If you prefer step-by-step installation:

### 1. Install Prerequisites

<details>
<summary><b>Ubuntu/Debian</b></summary>

```bash
sudo apt update
sudo apt install -y git curl zsh fzf tmux neovim python3 python3-pip
sudo apt install -y exa bat  # or eza batcat on newer versions
```
</details>

<details>
<summary><b>Fedora/RHEL</b></summary>

```bash
sudo dnf install -y git curl zsh eza bat fzf tmux neovim python3 python3-pip
```
</details>

<details>
<summary><b>Arch Linux</b></summary>

```bash
sudo pacman -S git curl zsh eza bat fzf tmux neovim python python-pip
```
</details>

### 2. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3. Install Zsh Plugins

```bash
# Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Syntax highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 4. Clone Dotfiles & Link

```bash
# Clone to ~/.dotfiles (recommended)
git clone https://github.com/maithaen/Dotfiles.git ~/.dotfiles

# Create symbolic links
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
ln -sf ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf

# Alacritty config
mkdir -p ~/.config/alacritty
ln -sf ~/.dotfiles/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

# Convenience link
ln -sf ~/.dotfiles ~/.config/dotfiles
```

### 5. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

### 6. Install Python Dependencies

```bash
pip3 install rich requests --user
```

---

## 📁 Repository Structure

```
~/.dotfiles/  (or wherever you clone it)
├── .zshrc                          # Zsh configuration & aliases
├── CLAUDE.md                       # AI assistant context documentation
├── README.md                       # This file - User documentation
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
    └── requirements.txt           # Python dependencies
```

**After installation, symlinks are created:**
```
~/.zshrc                           → ~/.dotfiles/.zshrc
~/.tmux.conf                       → ~/.dotfiles/tmux/tmux.conf
~/.config/alacritty/alacritty.yml  → ~/.dotfiles/alacritty/alacritty.yml
~/.config/dotfiles                 → ~/.dotfiles (convenience link)
```

---

## 🐍 Python CLI Tools

### Quick Setup with UV (Recommended)

[UV](https://docs.astral.sh/uv/) is a fast Python package manager. Use it for easy setup:

```bash
# Install UV (if not installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Run the pycli setup script
cd ~/.dotfiles/pycli && python3 setup_pycli.py

# Or use uv directly
uv run ~/.dotfiles/pycli/setup_pycli.py
```

The setup script will:
- Install UV (if needed)
- Install dependencies from requirements.txt (rich, requests)
- Make scripts executable
- Create wrapper scripts in `~/.local/bin`
- Create UV-compatible `pyproject.toml`

### Manual Setup (pip)

```bash
# Install from requirements.txt
pip3 install -r ~/.dotfiles/pycli/requirements.txt --user

# Or install manually
pip3 install rich requests --user

# Make scripts executable
chmod +x ~/.dotfiles/pycli/*.py
```

---

### orun - Ollama Run CLI

A beautiful CLI for interacting with Ollama models with streaming markdown output.

```bash
# Basic usage
orun "how to create a git branch"

# Specify model
orun "explain python decorators" -md=mistral:latest

# Save output to file
orun "write hello world in rust" > hello.rs
```

---

### devinit - Config File Generator

Generate configuration files for development projects.

```bash
# List available templates
devinit --list

# Generate single config
devinit gitignore
devinit pyproject
devinit eslint
devinit dockerfile

# Generate all configs for a project type
devinit --all --type python    # Python project configs
devinit --all --type node      # Node.js project configs
devinit --all --type go        # Go project configs
devinit --all --type rust      # Rust project configs
devinit --all --type full      # All available configs
```

**Available templates:**
`gitignore`, `gitattributes`, `editorconfig`, `prettier`, `eslint`, `typescript`, `pyproject`, `flake8`, `aider`, `golangci`, `dockerfile`, `dockerignore`, `vscode`, `makefile`, `github-actions`, `cargo`, `jest`

---

### devutils - Development Utilities

Various development utilities.

```bash
# Find command path (like Unix which)
devutils which python
devutils which node

# Enhanced directory listing
devutils ll
devutils ll /home/user

# Directory tree view  
devutils tree
devutils tree -L 5

# System information
devutils sysinfo

# Open file manager
devutils open .
devutils open ~/projects
```

---

### Running with UV

You can also run scripts directly with UV without installation:

```bash
# Run with uv
uv run --directory ~/.config/pycli python orun.py "your prompt"

# Or after setup, use the wrappers
orun "your prompt"
devinit gitignore
devutils ll
```


---

## 🔧 Customization

Edit these files to customize your environment:

| File | Purpose |
|------|---------|
| `~/.zshrc` | Shell aliases, functions, PATH |
| `~/.config/alacritty/alacritty.yml` | Terminal colors, fonts, opacity |
| `~/.tmux.conf` | Tmux keybindings, appearance |

---

## ❓ Troubleshooting

### Common Issues

**zsh plugins not loading**
```bash
# Verify plugins are installed
ls ~/.oh-my-zsh/custom/plugins/
# Should show: zsh-autosuggestions zsh-syntax-highlighting
```

**"command not found" errors**
```bash
# Reload shell configuration
source ~/.zshrc
```

**Permission denied on setup.sh**
```bash
chmod +x ~/.config/setup.sh
```

**bat/batcat alias not working**
```bash
# On Ubuntu, bat is installed as 'batcat'
# The .zshrc already handles this with: alias cat="batcat"
```

---

## 📝 License

MIT License - Feel free to use and modify.

---

## 🤝 Contributing

Suggestions and improvements are welcome! Please open an issue or submit a pull request.
