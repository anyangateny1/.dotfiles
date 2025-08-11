#!/bin/bash
# Install missing dependencies for better Neovim experience

echo "Installing missing dependencies for Neovim..."

# Install fd for telescope (better file searching)
if ! command -v fd &> /dev/null; then
    echo "Installing fd (fast file finder)..."
    sudo apt update && sudo apt install -y fd-find
    # Create symlink for fd command
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# Install tree-sitter CLI (optional but useful)
if ! command -v tree-sitter &> /dev/null; then
    echo "Installing tree-sitter CLI..."
    sudo npm install -g tree-sitter-cli
fi

# Optional: Install Python neovim module (for python plugins)
echo "Installing Python neovim module..."
pip3 install --user neovim

# Optional: Install Node.js neovim module (for node plugins)
echo "Installing Node.js neovim module..."
npm install -g neovim

# Fix tmux configuration (create or append to ~/.tmux.conf)
echo "Fixing tmux configuration..."
TMUX_CONF="$HOME/.tmux.conf"

# Check if tmux.conf exists, create if not
if [ ! -f "$TMUX_CONF" ]; then
    touch "$TMUX_CONF"
fi

# Add tmux optimizations if not already present
if ! grep -q "escape-time" "$TMUX_CONF"; then
    echo "# Neovim optimizations" >> "$TMUX_CONF"
    echo "set-option -sg escape-time 10" >> "$TMUX_CONF"
fi

if ! grep -q "focus-events" "$TMUX_CONF"; then
    echo "set-option -g focus-events on" >> "$TMUX_CONF"
fi

if ! grep -q "terminal-features" "$TMUX_CONF"; then
    echo "set-option -a terminal-features '*:RGB'" >> "$TMUX_CONF"
fi

echo "Dependencies installed! Please restart tmux for changes to take effect."
echo "Run: tmux kill-server && tmux" 