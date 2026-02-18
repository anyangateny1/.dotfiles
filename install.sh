#!/bin/bash
set -euo pipefail

# Dotfiles installer
# Creates symlinks from this repo into their expected locations.
# existing files are backed up to *.bak before overwriting.

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      echo "  [ok] $dest -> $src"
      return
    fi
    echo "  [..] Updating symlink $dest"
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "  [..] Backing up $dest to ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "  [ok] $dest -> $src"
}

echo "=== Dotfiles installer ==="
echo "Source: $DOTFILES_DIR"
echo ""

# Neovim
echo "--- Neovim ---"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux
echo "--- Tmux ---"
link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Alacritty
echo "--- Alacritty ---"
link "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"

echo ""
echo "=== Symlinks created ==="

# Offer to install Neovim plugin dependencies
if [ -x "$DOTFILES_DIR/nvim/install-deps.sh" ]; then
  echo ""
  read -rp "Install Neovim plugin dependencies? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    "$DOTFILES_DIR/nvim/install-deps.sh"
  fi
fi
