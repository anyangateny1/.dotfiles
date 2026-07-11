#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

unlink_dotfile() {
  local src="$1"
  local dest="$2"

  if [ ! -L "$dest" ]; then
    if [ -e "$dest" ]; then
      echo "  [skip] $dest exists but is not a symlink"
    else
      echo "  [ok] $dest is already absent"
    fi
    return
  fi

  local current
  current="$(readlink "$dest")"
  if [ "$current" != "$src" ]; then
    echo "  [skip] $dest points to $current"
    return
  fi

  rm "$dest"
  echo "  [ok] removed $dest"
}

echo "=== Dotfiles uninstaller ==="
echo "Source: $DOTFILES_DIR"
echo ""

# Bash
echo "--- Bash ---"
unlink_dotfile "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"
unlink_dotfile "$DOTFILES_DIR/bash/.bash_profile" "$HOME/.bash_profile"
unlink_dotfile "$DOTFILES_DIR/bash/.profile" "$HOME/.profile"
unlink_dotfile "$DOTFILES_DIR/bash/.bash_completion" "$HOME/.bash_completion"

# Neovim
echo "--- Neovim ---"
unlink_dotfile "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# Tmux
echo "--- Tmux ---"
unlink_dotfile "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# Git
echo "--- Git ---"
unlink_dotfile "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Alacritty
echo "--- Alacritty ---"
unlink_dotfile "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"

# C/C++ user-level defaults
echo "--- C/C++ ---"
if [ -f "$DOTFILES_DIR/.clangd" ]; then
  unlink_dotfile "$DOTFILES_DIR/.clangd" "$HOME/.clangd"
fi
if [ -f "$DOTFILES_DIR/.clang-format" ]; then
  unlink_dotfile "$DOTFILES_DIR/.clang-format" "$HOME/.clang-format"
fi

echo ""
echo "=== Symlinks removed ==="
echo "  bash, nvim, tmux, git, alacritty, clangd, clang-format"
