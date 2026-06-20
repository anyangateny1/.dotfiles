# dotfiles

Personal **full-stack** config: Bash, Tmux, Alacritty, Neovim, and clangd.
Installed with one script; managed across two git branches.

## Branches

| Branch | Machine | Includes |
|--------|---------|----------|
| **`home-pc`** | Home Fedora PC | **All** of: `bash/`, `tmux/`, `alacritty/`, `nvim/`, `install.sh` |
| **`work_vim`** | Work | **Same as home-pc** + `nvim/lua/custom/plugins/work-env.lua` |

Tmux, Alacritty, and Bash are **not** work-only or home-only — they live on `home-pc` and are inherited by `work_vim` when you rebase.

```bash
./install.sh    # symlinks everything (any branch)
```

Details: [docs/dotfiles.md](docs/dotfiles.md)

## Quick install

```bash
git checkout home-pc    # or work_vim at work
./install.sh
```

## Layout

| Tool | Repo | Symlink target |
|------|------|----------------|
| Bash | `bash/` | `~/.bashrc`, `~/.bash_profile`, `~/.profile`, `~/.bash_completion` |
| Neovim | `nvim/` | `~/.config/nvim` |
| Tmux | `tmux/tmux.conf` | `~/.tmux.conf` |
| Alacritty | `alacritty/` | `~/.config/alacritty` |

## Keep branches in sync

```bash
git checkout home-pc
# … edit bash/, tmux/, alacritty/, nvim/, …
git commit -am "..."

git checkout work_vim
git rebase home-pc
```

## Neovim docs

| Doc | Topic |
|-----|--------|
| [nvim/docs/setup-guide.md](nvim/docs/setup-guide.md) | Keymaps, LSP, completion |
| [nvim/docs/lsp.md](nvim/docs/lsp.md) | Adding language servers |
| [nvim/docs/debugging.md](nvim/docs/debugging.md) | DAP / `launch.json` |
