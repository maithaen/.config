# Tmux Configuration

This directory contains the configuration file for Tmux, a terminal multiplexer that allows you to manage multiple terminal sessions within a single window.

## Files

- **tmux.conf**: The main configuration file for Tmux. It includes custom key bindings, appearance settings, and other options to enhance your Tmux experience.

## Getting Started

1. **Install Tmux**:
   - On Debian/Ubuntu: `sudo apt install tmux`
   - On macOS: `brew install tmux`
   - On Windows: Use a package manager like Scoop or Chocolatey.

2. **Apply Configuration**:
   - Copy the `tmux.conf` file to your home directory as `.tmux.conf`:
     ```bash
     cp tmux/tmux.conf ~/.tmux.conf
     ```

3. **Start Tmux**:
   - Run `tmux` in your terminal to start a new session.

4. **Reload Configuration**:
   - If you make changes to the `tmux.conf` file, reload the configuration without restarting Tmux by running:
     ```bash
     tmux source-file ~/.tmux.conf
     ```

## Tips for New Users

- **Detach and Reattach Sessions**:
  - Detach from a session: `Ctrl-b d`
  - List sessions: `tmux list-sessions`
  - Reattach to a session: `tmux attach-session -t <session-name>`

- **Split Panes**:
  - Horizontal split: `Ctrl-b "`
  - Vertical split: `Ctrl-b %`

- **Navigate Panes**:
  - Use `Ctrl-b` followed by arrow keys to move between panes.

- **Kill Pane or Window**:
  - Kill the current pane: `Ctrl-b x`
  - Kill the current window: `Ctrl-b &`

For more information, refer to the [Tmux documentation](https://github.com/tmux/tmux/wiki).