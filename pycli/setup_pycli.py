#!/usr/bin/env python3
"""
PyCLI Setup Script - Configure Python CLI tools using UV

This script sets up the pycli tools with proper dependencies using UV (fast Python package manager).

Usage:
    # Install with uvx (recommended - no installation needed)
    uvx --from git+https://github.com/maithaen/.config pycli-setup

    # Or run directly
    python3 setup_pycli.py

    # Or with uv
    uv run setup_pycli.py
"""

import os
import shutil
import subprocess
import sys
from pathlib import Path

# ============================================
# Configuration
# ============================================

PYCLI_DIR = Path.home() / ".config" / "pycli"
REQUIRED_PACKAGES = ["rich", "requests"]

SCRIPTS = {
    "orun": "orun.py",
    "devinit": "devinit.py",
    "devutils": "devutils.py",
}

# ============================================
# Color Output
# ============================================


def print_success(msg: str):
    print(f"\033[92m✓\033[0m {msg}")


def print_error(msg: str):
    print(f"\033[91m✗\033[0m {msg}", file=sys.stderr)


def print_info(msg: str):
    print(f"\033[94m→\033[0m {msg}")


def print_warning(msg: str):
    print(f"\033[93m!\033[0m {msg}")


def print_header(msg: str):
    print(f"\n\033[1m\033[96m{'━' * 50}\033[0m")
    print(f"\033[1m\033[96m  {msg}\033[0m")
    print(f"\033[1m\033[96m{'━' * 50}\033[0m\n")


# ============================================
# Helper Functions
# ============================================


def command_exists(cmd: str) -> bool:
    """Check if a command exists in PATH."""
    return shutil.which(cmd) is not None


def run_cmd(cmd: list, check: bool = True) -> subprocess.CompletedProcess:
    """Run a command and return the result."""
    try:
        return subprocess.run(cmd, check=check, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        print_error(f"Command failed: {' '.join(cmd)}")
        if e.stderr:
            print(e.stderr)
        raise


# ============================================
# UV Installation
# ============================================


def install_uv():
    """Install UV if not already installed."""
    if command_exists("uv"):
        result = run_cmd(["uv", "--version"], check=False)
        print_success(f"UV is installed: {result.stdout.strip()}")
        return True

    print_info("Installing UV...")

    try:
        if sys.platform == "win32":
            # Windows
            run_cmd(["powershell", "-c", "irm https://astral.sh/uv/install.ps1 | iex"])
        else:
            # Linux/macOS
            run_cmd(["sh", "-c", "curl -LsSf https://astral.sh/uv/install.sh | sh"])

        print_success("UV installed successfully")
        print_warning("You may need to restart your terminal or run: source ~/.bashrc")
        return True

    except Exception as e:
        print_error(f"Failed to install UV: {e}")
        print_info("Visit https://docs.astral.sh/uv/ for manual installation")
        return False


# ============================================
# Dependencies Installation
# ============================================


def install_dependencies_with_uv():
    """Install Python dependencies using UV."""
    print_info("Installing Python dependencies with UV...")

    for package in REQUIRED_PACKAGES:
        try:
            run_cmd(["uv", "pip", "install", package, "--system"])
            print_success(f"Installed: {package}")
        except Exception:
            # Try with --user flag
            try:
                run_cmd(["uv", "pip", "install", package])
                print_success(f"Installed: {package}")
            except Exception as e:
                print_warning(f"Could not install {package}: {e}")


def install_dependencies_with_pip():
    """Fallback: Install dependencies with pip."""
    print_info("Installing Python dependencies with pip...")

    for package in REQUIRED_PACKAGES:
        try:
            run_cmd([sys.executable, "-m", "pip", "install", package, "--user"])
            print_success(f"Installed: {package}")
        except Exception as e:
            print_warning(f"Could not install {package}: {e}")


# ============================================
# Script Setup
# ============================================


def make_scripts_executable():
    """Make all pycli scripts executable."""
    if not PYCLI_DIR.exists():
        print_error(f"pycli directory not found: {PYCLI_DIR}")
        return False

    print_info("Making scripts executable...")

    for name, script in SCRIPTS.items():
        script_path = PYCLI_DIR / script
        if script_path.exists():
            script_path.chmod(0o755)
            print_success(f"Made executable: {script}")
        else:
            print_warning(f"Script not found: {script}")

    return True


def create_wrapper_scripts():
    """Create wrapper scripts in ~/.local/bin for direct CLI access."""
    local_bin = Path.home() / ".local" / "bin"
    local_bin.mkdir(parents=True, exist_ok=True)

    print_info(f"Creating wrapper scripts in {local_bin}...")

    for name, script in SCRIPTS.items():
        script_path = PYCLI_DIR / script
        wrapper_path = local_bin / name

        if not script_path.exists():
            print_warning(f"Script not found: {script}")
            continue

        # Create wrapper script
        wrapper_content = f"""#!/bin/sh
exec python3 "{script_path}" "$@"
"""
        wrapper_path.write_text(wrapper_content)
        wrapper_path.chmod(0o755)
        print_success(f"Created wrapper: {name}")

    # Check if ~/.local/bin is in PATH
    path_env = os.environ.get("PATH", "")
    if str(local_bin) not in path_env:
        print_warning(
            f'Add to your shell profile: export PATH="$HOME/.local/bin:$PATH"'
        )

    return True


def create_uv_scripts():
    """Create uvx-compatible entry points."""
    print_info("Creating UV tool scripts...")

    # Create pyproject.toml for the pycli package
    pyproject_path = PYCLI_DIR / "pyproject.toml"

    pyproject_content = """[project]
name = "pycli-tools"
version = "1.0.0"
description = "Personal Python CLI tools"
requires-python = ">=3.10"
dependencies = [
    "rich>=13.0",
    "requests>=2.28",
]

[project.scripts]
orun = "orun:main"
devinit = "devinit:main"
devutils = "devutils:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
"""

    pyproject_path.write_text(pyproject_content)
    print_success("Created pyproject.toml for UV compatibility")

    return True


# ============================================
# Verification
# ============================================


def verify_installation():
    """Verify the installation works."""
    print_info("Verifying installation...")

    # Check if rich is importable
    try:
        import importlib

        importlib.import_module("rich")
        print_success("rich module is available")
    except ImportError:
        print_warning("rich module not found - some features may not work")

    # Check if scripts exist
    for name, script in SCRIPTS.items():
        script_path = PYCLI_DIR / script
        if script_path.exists():
            print_success(f"Found: {script}")
        else:
            print_error(f"Missing: {script}")

    return True


# ============================================
# Main Setup
# ============================================


def main():
    print_header("PyCLI Setup - UV/Python CLI Tools")

    print("This script will:")
    print("  1. Install UV (if not present)")
    print("  2. Install Python dependencies (rich, requests)")
    print("  3. Make scripts executable")
    print("  4. Create wrapper scripts in ~/.local/bin")
    print("  5. Create UV-compatible pyproject.toml")
    print()

    # Step 1: Install UV
    print_header("Step 1: UV Package Manager")
    uv_available = install_uv()

    # Step 2: Install dependencies
    print_header("Step 2: Python Dependencies")
    if uv_available and command_exists("uv"):
        install_dependencies_with_uv()
    else:
        install_dependencies_with_pip()

    # Step 3: Make scripts executable
    print_header("Step 3: Script Permissions")
    make_scripts_executable()

    # Step 4: Create wrapper scripts
    print_header("Step 4: Wrapper Scripts")
    create_wrapper_scripts()

    # Step 5: Create UV-compatible config
    print_header("Step 5: UV Compatibility")
    create_uv_scripts()

    # Verify
    print_header("Verification")
    verify_installation()

    # Summary
    print_header("Setup Complete!")

    print("\033[92mAvailable commands:\033[0m")
    print("  orun      - Ollama Run CLI")
    print("  devinit   - Config file generator")
    print("  devutils  - Development utilities")
    print()
    print("\033[93mUsage with UV:\033[0m")
    print("  uv run --directory ~/.config/pycli orun 'your prompt'")
    print("  uv run --directory ~/.config/pycli devinit --list")
    print()
    print("\033[93mOr add to PATH and use directly:\033[0m")
    print('  export PATH="$HOME/.local/bin:$PATH"')
    print("  orun 'your prompt'")
    print()
    print("\033[1m\033[92mEnjoy your CLI tools! 🚀\033[0m")


if __name__ == "__main__":
    main()
