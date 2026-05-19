# Neovim setup guide

Part of the **full dotfiles** repo (`bash/`, `tmux/`, `alacritty/`, `nvim/`, `.clangd`).
Both `home-pc` and `work_vim` branches install all of them via `./install.sh` at the repo root.

Stack overview: [../../docs/dotfiles.md](../../docs/dotfiles.md)

Shell `fzf` key bindings live in `bash/.bashrc` (Fedora path fixed).

---

## Quick reference

### LSP & languages

| Language | LSP file | Mason package | Format on save |
|----------|----------|---------------|----------------|
| C/C++ | `lsp/clangd.lua` | `clangd` | `clang-format` (if style file exists) |
| Go | `lsp/gopls.lua` | `gopls` | `gofumpt`, `goimports` |
| Python | `lsp/pyright.lua` | `pyright` | `ruff` |
| JS/TS/React | `lsp/ts_ls.lua`, `lsp/eslint.lua` | `typescript-language-server`, `eslint-lsp` | `eslint_d`, `prettier` |
| Lua | `lsp/lua_ls.lua` | `lua-language-server` | `stylua` |

**Add a new language:** see [lsp.md](./lsp.md) — create `lsp/<name>.lua`, `:MasonInstall …`, `:restart`.

### Debugging

| Key | Action |
|-----|--------|
| `<F5>` | Start / continue |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<F7>` | Toggle DAP UI |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>dd` | Pick launch configuration |

**Per-project config:** copy `~/.config/nvim/launch.json.example` → `.vscode/launch.json` and edit paths/args.

Full guide: [debugging.md](./debugging.md).

### Spellcheck

| What | How |
|------|-----|
| Auto on | `markdown`, `text`, `gitcommit`, `gitrebase` buffers |
| Toggle any buffer | `<leader>ts` |

Spell is **off** in code buffers by default (no more red squiggles in C++).

### Completion

| Key (insert mode) | Action |
|-------------------|--------|
| `<C-Space>` | Trigger completion |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-y>` | Confirm selection |
| `<C-l>` | Jump to next LSP snippet placeholder (when applicable) |
| `<C-h>` | Jump to previous LSP snippet placeholder |
| `<C-b>` / `<C-f>` | Scroll completion docs |

**Autopairs:** closing `)`, `}`, `"` is inserted when you confirm a completion item that includes an opening pair.

LuaSnip remains for **LSP snippet expansion** only (e.g. function stubs from clangd), not a prebuilt snippet library.

### Shell (bash) — fzf

After opening a new terminal, these work if `fzf` is installed:

| Key | Action |
|-----|--------|
| `Ctrl-T` | Fuzzy-find files (insert path) |
| `Ctrl-R` | Fuzzy-search command history |
| `Alt-C` | Fuzzy-find directories (`cd`) |

Fedora installs bindings at `/usr/share/fzf/shell/key-bindings.bash` (now sourced automatically from `.bashrc`).

---

## Files added or changed

### New LSP configs

- `lsp/pyright.lua` — Python language server
- `lsp/gopls.lua` — Go language server

### New docs

| File | Purpose |
|------|---------|
| [lsp.md](./lsp.md) | How to add any LSP server |
| [debugging.md](./debugging.md) | `launch.json`, DAP, troubleshooting |
| This file | Overview and keymaps |

### Templates

- `launch.json.example` — copy into your repo as `.vscode/launch.json`

### Config changes

| File | Change |
|------|--------|
| `lua/custom/options.lua` | Global spell removed |
| `lua/custom/autocmds.lua` | Spell on for prose filetypes |
| `lua/custom/keymaps.lua` | `<leader>ts` spell toggle |
| `lua/custom/plugins/lsp.lua` | Mason: `gopls`, `gofumpt`, `goimports` |
| `lua/custom/plugins/formatting.lua` | Go formatters |
| `lua/custom/plugins/completion.lua` | cmp + autopairs |
| `lua/custom/plugins/debug.lua` | Project `launch.json` only (no hardcoded paths) |
| `bash/.bashrc` | fzf key-bindings path fix for Fedora |

---

## First-time setup after pull

```bash
# 1. Reload shell (fzf bindings)
source ~/.bashrc

# 2. Open Neovim and sync plugins
nvim
:Lazy sync

# 3. Install tools (if Mason did not auto-install)
:MasonInstall gopls gofumpt goimports pyright codelldb delve debugpy

# 4. Restart
:restart
```

---

## Common workflows

### C++ project

1. Generate `compile_commands.json` (CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`).
2. Open project; clangd attaches automatically.
3. `<leader>ch` — switch header/source (clangd).
4. `<leader>f` — format (only if `.clang-format` or `clang-format.yaml` exists).
5. Debug: copy `launch.json.example` → `.vscode/launch.json`, set `program` to your binary, `<F5>`.

### Go project

1. Open folder with `go.mod`.
2. `gopls` provides navigation, rename, diagnostics.
3. Format on save via `gofumpt` + `goimports`.
4. Debug: use `"type": "go"` entry in `launch.json`.

### Web (JS/TS)

1. Open folder with `package.json` / `tsconfig.json`.
2. `ts_ls` + `eslint` (when eslint config exists).
3. `<leader>f` — eslint_d + prettier.

### Random / new language

1. Read [lsp.md](./lsp.md).
2. Create `lsp/<server>.lua`.
3. `:MasonInstall <package>`.
4. `:restart`.

Optional: add Treesitter parser in `lua/custom/plugins/tree-sitter.lua`, run `:TSInstall <parser>`.

---

## Related built-in / existing features (unchanged)

These were already in your config; listed here so this doc is self-contained.

| Area | Keys / commands |
|------|-----------------|
| File tree | `<leader>e`, `\` |
| Telescope | `<leader>sf` files, `<leader>sg` grep, `<leader>/` buffer fuzzy |
| LSP (Lspsaga) | `gd` definition, `K` hover, `gr` refs, `<leader>ca` actions |
| Git | gitsigns `<leader>h*`, fugitive, diffview |
| Harpoon | `<leader>ha` add, `<leader>hh` menu, `<leader>1`–`4` jump |
| Format | `<leader>f` |
| Trouble diagnostics | `<leader>xx` |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `fzf key-bindings.bash: No such file` | Pull latest `.bashrc`; `source ~/.bashrc` |
| Python has no LSP | `:MasonInstall pyright`, check `lsp/pyright.lua` exists |
| Go has no LSP | `:MasonInstall gopls` |
| Debug: no configs | Add `.vscode/launch.json` in project root |
| LSP snippets (placeholders) | Use `<C-l>` / `<C-h>` after confirming an LSP snippet item |
| Mason package missing | `:Mason` → install → `:restart` |

More detail: [debugging.md](./debugging.md), [lsp.md](./lsp.md).
