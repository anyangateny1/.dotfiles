# Neovim setup guide

Part of the full dotfiles repo. `work_vim` keeps the cleaner `home-pc` Neovim structure, with the default toolchain centered on Python, C/C++, Markdown, plus Lua and JSON for maintaining the config itself.

## Quick reference

### LSP & languages

| Language | LSP file | Mason package | Format / lint |
|----------|----------|---------------|---------------|
| C/C++ | `lsp/clangd.lua` | `clangd` | `clang-format`, `clang-tidy` via `clangd` |
| Python | `lsp/pyright.lua` | `pyright` | Ruff for lint/imports/fix/format |
| Markdown | `lsp/markdown_oxide.lua` | `markdown-oxide` | `markdownlint-cli2` |
| JSON | `lsp/jsonls.lua` | `json-lsp` | LSP only |
| Lua | `lsp/lua_ls.lua` | `lua-language-server` | `stylua` |

Add a new language by creating `lsp/<name>.lua` and adding the Mason package to `lua/custom/plugins/lsp.lua`.

### Tool config files

Put config in the tool's own project files. Neovim does not pass config paths for these tools.

| Tool | Where to put config |
|------|---------------------|
| Ruff | `pyproject.toml`, `ruff.toml`, `.ruff.toml` |
| Pyright | `pyrightconfig.json` |
| clangd | `.clangd`, `compile_commands.json`, `~/.clangd`, or user config at `~/.config/clangd/config.yaml` |
| clang-format | `.clang-format`, `_clang-format`, `clang-format.yaml`, or `~/.clang-format` |
| clang-tidy | `.clang-tidy` |
| markdownlint-cli2 | `.markdownlint-cli2.jsonc`, `.markdownlint-cli2.yaml`, `.markdownlint-cli2.yml`, `.markdownlint-cli2.cjs` |
| markdown-oxide | `.markdownoxide.toml` or `.obsidian` root |

`clangd` is started with `--enable-config` and `--clang-tidy`. The dotfiles install adds `~/.clangd`, which defaults C++ files and headers to C++23 when a project does not override it. It still uses `compile_commands.json` when available by walking upward from the source file. If a project uses a separate build directory, keep `compile_commands.json` where clangd can find it, or add the compile command location to `.clangd`.

The dotfiles install also adds `~/.clang-format`, so format-on-save and `<leader>f` can sort and group includes even when a project has no local style file. A project-local style file wins when present.

`--clang-tidy` means clangd runs clang-tidy checks inside LSP diagnostics. The standalone `clang-tidy` CLI is still separate, and `clang-format` is the tool that formats code and sorts includes.

### Ruff and Pylint rules

Ruff is the editor linter. It can enable Pylint-derived rules with the `PL` prefix, but this is not exact full Pylint parity. Use full Pylint separately in a project or CI only when you need Pylint-specific behavior.

Example `ruff.toml`:

```toml
line-length = 120

[lint]
select = ["E", "F", "I", "B", "UP", "SIM", "PL"]
ignore = []

[format]
quote-style = "single"
indent-style = "space"
```

Equivalent `pyproject.toml`:

```toml
[tool.ruff]
line-length = 120

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP", "SIM", "PL"]
ignore = []

[tool.ruff.format]
quote-style = "single"
indent-style = "space"
```

## First-time setup after pull

```bash
source ~/.bashrc
nvim
:Lazy sync
:MasonInstall clangd pyright markdown-oxide json-lsp stylua clang-format ruff markdownlint-cli2
:restart
```

## Common workflows

### C++ project

1. Generate `compile_commands.json` when your build system supports it.
2. Add project `.clang-format` only when you need to override the home default.
3. Add `.clang-tidy` for diagnostics policy when the project needs one.
4. Use `<leader>ch` to switch header/source.
5. Use `<leader>f` to format and sort includes.

### Python project

1. Put Ruff config in `pyproject.toml`, `ruff.toml`, or `.ruff.toml`.
2. Enable `PL` in Ruff if you want Pylint-derived rules.
3. `pyright` handles types; Ruff handles lint diagnostics and `<leader>f` runs Ruff import/fix/format.

### Markdown project

1. Put markdownlint rules in a supported markdownlint config file.
2. Add `.markdownoxide.toml` to opt a notes root into `markdown-oxide` outside Obsidian vaults.
3. Markdown text width and spell defaults are set in `lua/custom/autocmds.lua`.

## Files to know

| File | Purpose |
|------|---------|
| `lua/custom/plugins/lsp.lua` | Extensible Mason + LSP auto-discovery core |
| `lua/custom/plugins/formatting.lua` | Ruff + clang-format wiring |
| `lua/custom/plugins/lint.lua` | Ruff + markdownlint wiring |
| `lua/custom/autocmds.lua` | Markdown/text editor defaults |
| `lua/custom/plugins/work-env.lua` | Work-machine-only overlay |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Python has no LSP | `:MasonInstall pyright`, check `lsp/pyright.lua` exists |
| Ruff rules are too light | Add `select = ["E", "F", "I", "PL"]` or a broader list in Ruff config |
| Markdown lint config not found | Add a markdownlint-cli2 config file at the project root |
| Markdown LSP does not attach | Add `.markdownoxide.toml` or use an `.obsidian` root |
| C/C++ format is skipped | Run `./install.sh` so `~/.clang-format` exists, or add a project `.clang-format` |
