#!/usr/bin/env python3
"""
DevUtils - Development Utility Functions for Linux/WSL

Provides enhanced directory listing, file operations, system utilities,
and development tools with beautiful output.

Commands:
    which <command>     Find command path (like Unix which)
    ll [path]           Enhanced directory listing with lsd
    tree [path]         Directory tree view with eza
    sysinfo             Show system information with neofetch
    open [path]         Open file manager at path

Usage:
    devutils which python
    devutils ll
    devutils tree -L 5
    devutils open .
"""

import argparse
import os
import shutil
import subprocess
import sys

# Rich for beautiful output
try:
    from rich.console import Console
    from rich.table import Table

    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False

console = Console() if RICH_AVAILABLE else None

# ============================================
# Helper Functions
# ============================================


def print_success(message: str):
    if RICH_AVAILABLE:
        console.print(f"[green]✓[/green] {message}")
    else:
        print(f"✓ {message}")


def print_error(message: str):
    if RICH_AVAILABLE:
        console.print(f"[red]✗[/red] {message}")
    else:
        print(f"✗ {message}", file=sys.stderr)


def print_warning(message: str):
    if RICH_AVAILABLE:
        console.print(f"[yellow]![/yellow] {message}")
    else:
        print(f"! {message}")


def print_info(message: str):
    if RICH_AVAILABLE:
        console.print(f"[blue]→[/blue] {message}")
    else:
        print(f"→ {message}")


def command_exists(cmd: str) -> bool:
    """Check if a command exists in PATH."""
    return shutil.which(cmd) is not None


def run_command(cmd: list, capture: bool = False) -> subprocess.CompletedProcess:
    """Run a command and handle errors."""
    try:
        if capture:
            return subprocess.run(cmd, capture_output=True, text=True)
        else:
            return subprocess.run(cmd)
    except FileNotFoundError:
        print_error(f"Command not found: {cmd[0]}")
        sys.exit(1)
    except Exception as e:
        print_error(f"Error running command: {e}")
        sys.exit(1)


# ============================================
# Command: which
# ============================================


def cmd_which(args):
    """Find the path of a command (like Unix which)."""
    command = args.command

    path = shutil.which(command)

    if path:
        if RICH_AVAILABLE:
            console.print(f"[green]{path}[/green]")
        else:
            print(path)
    else:
        print_error(f"Command '{command}' not found")
        sys.exit(1)


# ============================================
# Command: ll (enhanced ls)
# ============================================


def cmd_ll(args):
    """Enhanced directory listing using lsd or eza."""
    path = args.path or "."

    # Print current directory
    if RICH_AVAILABLE:
        console.print(f"[cyan]{os.path.abspath(path)}[/cyan]")
    else:
        print(os.path.abspath(path))

    # Try lsd first, then eza, then fallback to ls
    if command_exists("lsd"):
        cmd = [
            "lsd",
            "-1",
            "-lA",
            "--human-readable",
            "--group-directories-first",
            "--extensionsort",
            "--blocks",
            "permission",
            "--blocks",
            "size",
            "--blocks",
            "date",
            "--blocks",
            "name",
            path,
        ]
        run_command(cmd)
    elif command_exists("eza"):
        cmd = ["eza", "-la", "--icons", "--group-directories-first", "--git", path]
        run_command(cmd)
    elif command_exists("exa"):
        cmd = ["exa", "-la", "--icons", "--group-directories-first", "--git", path]
        run_command(cmd)
    else:
        # Fallback to standard ls
        cmd = ["ls", "-la", "--color=auto", path]
        run_command(cmd)


# ============================================
# Command: tree
# ============================================


def cmd_tree(args):
    """Display directory tree using eza."""
    path = args.path or "."
    level = args.level or 3

    # Build ignore patterns
    ignore_patterns = ".git|.venv|node_modules|__pycache__|*.pyc|dist|build|*.egg-info"

    if command_exists("eza"):
        cmd = [
            "eza",
            "--tree",
            f"-L{level}",
            "--icons",
            "--classify",
            "--group-directories-first",
            f"--ignore-glob={ignore_patterns}",
            path,
        ]
        run_command(cmd)
    elif command_exists("exa"):
        cmd = [
            "exa",
            "--tree",
            f"-L{level}",
            "--icons",
            "--classify",
            "--group-directories-first",
            f"--ignore-glob={ignore_patterns}",
            path,
        ]
        run_command(cmd)
    elif command_exists("tree"):
        cmd = ["tree", "-L", str(level), "-C", "--dirsfirst", path]
        run_command(cmd)
    else:
        print_error(
            "Neither 'eza', 'exa', nor 'tree' found. Please install one of them."
        )
        sys.exit(1)


# ============================================
# Command: sysinfo (neofetch)
# ============================================


def cmd_sysinfo(args):
    """Display system information using neofetch or fastfetch."""
    if command_exists("neofetch"):
        run_command(["neofetch"])
    elif command_exists("fastfetch"):
        run_command(["fastfetch"])
    else:
        # Fallback: basic system info
        print_warning("neofetch/fastfetch not found. Showing basic info...")
        import platform

        if RICH_AVAILABLE:
            table = Table(title="System Information")
            table.add_column("Property", style="cyan")
            table.add_column("Value", style="green")

            table.add_row("OS", platform.system())
            table.add_row("Release", platform.release())
            table.add_row("Version", platform.version())
            table.add_row("Machine", platform.machine())
            table.add_row("Processor", platform.processor())
            table.add_row("Python", platform.python_version())
            table.add_row("Node", platform.node())

            console.print(table)
        else:
            print(f"OS: {platform.system()}")
            print(f"Release: {platform.release()}")
            print(f"Version: {platform.version()}")
            print(f"Machine: {platform.machine()}")
            print(f"Python: {platform.python_version()}")


# ============================================
# Command: open (file manager)
# ============================================


def cmd_open(args):
    """Open file manager at specified path."""
    path = args.path or "."
    abs_path = os.path.abspath(path)

    if not os.path.exists(abs_path):
        print_error(f"Path does not exist: {abs_path}")
        sys.exit(1)

    # Detect platform and open file manager
    system = sys.platform

    try:
        if system == "darwin":
            # macOS
            subprocess.run(["open", abs_path])
        elif system == "win32":
            # Windows
            subprocess.run(["explorer.exe", abs_path])
        elif system.startswith("linux"):
            # Linux - try various file managers
            if os.environ.get("WSL_DISTRO_NAME"):
                # WSL - use Windows explorer
                # Convert Linux path to Windows path
                wsl_path = subprocess.run(
                    ["wslpath", "-w", abs_path], capture_output=True, text=True
                ).stdout.strip()
                subprocess.run(["explorer.exe", wsl_path])
            elif command_exists("xdg-open"):
                subprocess.run(["xdg-open", abs_path])
            elif command_exists("nautilus"):
                subprocess.run(["nautilus", abs_path])
            elif command_exists("dolphin"):
                subprocess.run(["dolphin", abs_path])
            elif command_exists("thunar"):
                subprocess.run(["thunar", abs_path])
            else:
                print_error("No file manager found")
                sys.exit(1)
        else:
            print_error(f"Unsupported platform: {system}")
            sys.exit(1)

        print_success(f"Opened: {abs_path}")
    except Exception as e:
        print_error(f"Failed to open file manager: {e}")
        sys.exit(1)


# ============================================
# Main Entry Point
# ============================================


def main():
    parser = argparse.ArgumentParser(
        description="DevUtils - Development Utility Functions",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  devutils which python         Find Python path
  devutils ll                   List current directory
  devutils ll /home             List /home directory
  devutils tree                 Show directory tree (depth 3)
  devutils tree -L 5            Show directory tree (depth 5)
  devutils sysinfo              Show system information
  devutils open .               Open current dir in file manager
        """,
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # which command
    which_parser = subparsers.add_parser("which", help="Find command path")
    which_parser.add_argument("command", help="Command to find")
    which_parser.set_defaults(func=cmd_which)

    # ll command
    ll_parser = subparsers.add_parser("ll", help="Enhanced directory listing")
    ll_parser.add_argument(
        "path", nargs="?", help="Path to list (default: current dir)"
    )
    ll_parser.set_defaults(func=cmd_ll)

    # tree command
    tree_parser = subparsers.add_parser("tree", help="Directory tree view")
    tree_parser.add_argument(
        "path", nargs="?", help="Path to show (default: current dir)"
    )
    tree_parser.add_argument(
        "-L", "--level", type=int, default=3, help="Max depth (default: 3)"
    )
    tree_parser.set_defaults(func=cmd_tree)

    # sysinfo command
    sysinfo_parser = subparsers.add_parser("sysinfo", help="Show system information")
    sysinfo_parser.set_defaults(func=cmd_sysinfo)

    # open command
    open_parser = subparsers.add_parser("open", help="Open in file manager")
    open_parser.add_argument(
        "path", nargs="?", help="Path to open (default: current dir)"
    )
    open_parser.set_defaults(func=cmd_open)

    args = parser.parse_args()

    if args.command:
        args.func(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
