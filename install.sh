#!/bin/bash
set -euo pipefail

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

# Bash
echo "--- Bash ---"
link "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
link "$DOTFILES_DIR/bash/.bash_profile" "$HOME/.bash_profile"
link "$DOTFILES_DIR/bash/.profile" "$HOME/.profile"
link "$DOTFILES_DIR/bash/.bash_completion" "$HOME/.bash_completion"

# Neovim
echo "--- Neovim ---"
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux
echo "--- Tmux ---"
link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Git
echo "--- Git ---"
link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Alacritty
echo "--- Alacritty ---"
link "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"

# C/C++ user-level defaults
echo "--- C/C++ ---"
if [ -f "$DOTFILES_DIR/.clangd" ]; then
  link "$DOTFILES_DIR/.clangd" "$HOME/.clangd"
fi
if [ -f "$DOTFILES_DIR/.clang-format" ]; then
  link "$DOTFILES_DIR/.clang-format" "$HOME/.clang-format"
fi

echo ""
echo "=== Symlinks created ==="
echo "  bash, nvim, tmux, git, alacritty, clangd, clang-format"

# Offer to install Neovim plugin dependencies
if [ -x "$DOTFILES_DIR/nvim/install-deps.sh" ]; then
  echo ""
  read -rp "Install Neovim plugin dependencies? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    "$DOTFILES_DIR/nvim/install-deps.sh"
  fi
fi
