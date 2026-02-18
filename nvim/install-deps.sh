#!/bin/bash
set -euo pipefail

# Installs only what Neovim plugins need to function.
# Developer tools (gcc, clang, node, etc.) are your responsibility.
#
# Usage:
#   chmod +x install-deps.sh && ./install-deps.sh

echo "=== Neovim plugin dependency installer ==="
echo ""

# Detect package manager
if command -v apt &>/dev/null; then
  PKG_MGR="apt"
  INSTALL="sudo apt install -y"
  UPDATE="sudo apt update"
elif command -v dnf &>/dev/null; then
  PKG_MGR="dnf"
  INSTALL="sudo dnf install -y"
  UPDATE="sudo dnf check-update || true"
elif command -v pacman &>/dev/null; then
  PKG_MGR="pacman"
  INSTALL="sudo pacman -S --noconfirm"
  UPDATE="sudo pacman -Sy"
elif command -v brew &>/dev/null; then
  PKG_MGR="brew"
  INSTALL="brew install"
  UPDATE="brew update"
else
  echo "ERROR: No supported package manager found (apt, dnf, pacman, brew)"
  exit 1
fi

echo "Detected package manager: $PKG_MGR"
echo ""

install_if_missing() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if command -v "$cmd" &>/dev/null; then
    echo "  [ok] $cmd"
  else
    echo "  [..] Installing $pkg..."
    $INSTALL "$pkg" 2>/dev/null || echo "  [!!] Failed to install $pkg"
  fi
}

# Check Neovim
if ! command -v nvim &>/dev/null; then
  echo "WARNING: Neovim is not installed. Install Neovim >= 0.11 first."
  echo "  See: https://github.com/neovim/neovim/releases"
else
  echo "Neovim: $(nvim --version | head -1)"
fi

echo ""
$UPDATE 2>/dev/null || true

# --- Required by plugins ---
echo "--- Telescope dependencies ---"

# ripgrep: required by Telescope live_grep
install_if_missing rg ripgrep

# fd: used by Telescope find_files for speed
if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
  echo "  [ok] fd"
else
  echo "  [..] Installing fd..."
  if [ "$PKG_MGR" = "apt" ]; then
    $INSTALL fd-find
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true
  else
    $INSTALL fd
  fi
fi

# make: needed to build telescope-fzf-native
install_if_missing make make

echo ""
echo "--- Treesitter dependencies ---"

# C compiler: required by nvim-treesitter to compile parsers
if command -v cc &>/dev/null || command -v gcc &>/dev/null; then
  echo "  [ok] C compiler"
else
  echo "  [..] Installing gcc (needed to compile treesitter parsers)..."
  $INSTALL gcc 2>/dev/null || echo "  [!!] Failed to install gcc"
fi

echo ""
echo "=== Done! ==="
echo "Run :checkhealth to verify everything is working."
