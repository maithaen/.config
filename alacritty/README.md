# Alacritty Terminal Configuration

This directory contains the configuration file for [Alacritty](https://github.com/alacritty/alacritty), a modern, GPU-accelerated terminal emulator.

## Configuration File

- `alacritty.yml`: Main configuration file for Alacritty

## Installation

The setup script automatically creates a symlink from `~/.config/alacritty/alacritty.yml` to this file.

## Customization

To customize your Alacritty configuration:

1. Edit this `alacritty.yml` file
2. Changes will take effect when you restart Alacritty or reload the configuration

## Key Features

- GPU-accelerated rendering
- Cross-platform support (Linux, macOS, Windows)
- Vi mode and scrollback
- Configurable key bindings and colors
- Dynamic window resizing

## Default Configuration

The default configuration includes:
- Modern color scheme
- Optimized font settings
- Key bindings for common operations
- Window transparency options

## Troubleshooting

If Alacritty doesn't start after configuration changes:
1. Check for syntax errors in `alacritty.yml`
2. Run `alacritty --config-file /path/to/alacritty.yml` to test
3. Check logs for error messages
