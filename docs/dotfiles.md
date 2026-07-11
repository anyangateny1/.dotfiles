# Full dotfiles stack

Both **`home-pc`** and **`work_vim`** install **everything below** via `./install.sh`.
The only branch difference is Neovim’s `work-env.lua` overlay on `work_vim`.

## What gets symlinked

| Component | Repo path | Installed to |
|-----------|-----------|--------------|
| **Bash** | `bash/.bashrc` | `~/.bashrc` |
| | `bash/.bash_profile` | `~/.bash_profile` |
| | `bash/.profile` | `~/.profile` |
| | `bash/.bash_completion/` | `~/.bash_completion/` |
| **Neovim** | `nvim/` | `~/.config/nvim` |
| **Tmux** | `tmux/tmux.conf` | `~/.tmux.conf` |
| **Git** | `git/.gitconfig` | `~/.gitconfig` |
| **Alacritty** | `alacritty/` | `~/.config/alacritty` |
| **clangd** | `.clangd` | `~/.clangd` |
| **clang-format** | `.clang-format` | `~/.clang-format` |

## Branches

```
home-pc   ──►  bash, tmux, git, alacritty, nvim, .clangd, .clang-format, install.sh, uninstall.sh
                  │
work_vim  ──►  same + nvim/lua/custom/plugins/work-env.lua
```

| Branch | Machines | Extra |
|--------|----------|--------|
| `home-pc` | Home PC | Base for all shared config |
| `work_vim` | Work | `work-env.lua` (Telescope monorepo ignores) |

**Tmux, Alacritty, and Bash are identical on both branches** — always updated on `home-pc`, then `git rebase home-pc` on `work_vim`.

## Install

```bash
git clone <repo> ~/.dotfiles   # or your path
cd ~/.dotfiles
git checkout home-pc          # or work_vim on work machine
./install.sh
./uninstall.sh
```

## Bash (`bash/.bashrc`)

- `EDITOR` / `VISUAL` → `nvim`
- **fzf** key bindings (Fedora: `/usr/share/fzf/shell/key-bindings.bash`)
  - `Ctrl-T` — fuzzy file picker
  - `Ctrl-R` — fuzzy history
  - `Alt-C` — fuzzy cd
- History: no duplicates, shared across sessions
- Cargo env sourced if present

Requires: `fzf` package (`dnf install fzf` on Fedora).

## Tmux (`tmux/tmux.conf`)

Shared on **both** branches (merged from old home + work remote configs).

- Prefix: `Ctrl-b`
- Vi-style: `h/j/k/l` panes, `|` horizontal split, `_` vertical split
- `Ctrl-b R` — reload config
- `Ctrl-b Alt-c` — attach session at pane’s current directory
- `Ctrl-b x` — kill pane, `Ctrl-b X` — kill window
- `renumber-windows on`
- **tmux-resurrect** plugin (needs [TPM](https://github.com/tmux-plugins/tpm)):

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# In tmux: Prefix + I  (install plugins)
```

## Alacritty (`alacritty/alacritty.toml`)

- Font: JetBrains Mono Nerd Font, size 10
- Theme: edit `alacritty.toml` or add `[import]` for a theme file

Optional themes (not in repo): clone [alacritty-theme](https://github.com/alacritty/alacritty-theme) to `alacritty/themes/` (gitignored).

## Git (`git/.gitconfig`)

Shared Git defaults, aliases, editor, and rebase behavior installed to `~/.gitconfig`.

## clangd (`.clangd`)

Shared C++ LSP tweaks: defaults C++ files and headers to C++23, strips noisy compile flags, and suppresses diagnostics under `build/` and `subprojects/`.
Used by Neovim’s clangd on any machine with this dotfiles install.

## clang-format (`.clang-format`)

Shared C++ formatting defaults: LLVM base style and automatic include sorting/grouping.
Project-local `.clang-format` files override this home-level default.

## Neovim

See `nvim/docs/setup-guide.md`, `nvim/docs/lsp.md`, `nvim/docs/debugging.md`.

## Syncing home → work

```bash
git checkout home-pc
# edit bash/, tmux/, alacritty/, nvim/, etc.
git add -A && git commit -m "..."

git checkout work_vim
git rebase home-pc
git push origin work_vim
```

Any change under `bash/`, `tmux/`, or `alacritty/` on `home-pc` automatically applies to `work_vim` after rebase.
