# Adding a language server

LSP servers are auto-discovered from `~/.config/nvim/lsp/*.lua`. The filename (without `.lua`)
must match the name passed to `vim.lsp.enable` — e.g. `lsp/pyright.lua` → `pyright`.

## Three steps

1. **Create** `lsp/<server_name>.lua` returning a `vim.lsp.Config` table.
2. **Install** the binary: `:MasonInstall <package>` (or your system package manager).
3. **Restart** Neovim, or `:restart`.

No edits to `lsp.lua` are required.

## Template

```lua
---@type vim.lsp.Config
return {
  cmd = { 'my-language-server', '--stdio' },
  filetypes = { 'myft' },
  root_markers = { '.git', 'project-root-file' },
  settings = {
    -- server-specific settings
  },
}
```

Find the Mason package name with `:Mason` and match the executable in `cmd`.

## Examples in this config

| File | Mason package | Languages |
|------|---------------|-----------|
| `clangd.lua` | `clangd` | C, C++ |
| `pyright.lua` | `pyright` | Python |
| `markdown_oxide.lua` | `markdown-oxide` | Markdown |
| `jsonls.lua` | `json-lsp` | JSON, JSONC |
| `lua_ls.lua` | `lua-language-server` | Lua |

## Mason package vs LSP name

They are not always the same:

| Mason | `lsp/` filename | `cmd` binary |
|-------|-----------------|--------------|
| `lua-language-server` | `lua_ls.lua` | `lua-language-server` |
| `pyright` | `pyright.lua` | `pyright-langserver` |
| `json-lsp` | `jsonls.lua` | `vscode-json-language-server` |

Use `:Mason` → package → “Instructions” for the exact command.

## Optional: format / lint

- **Format on save** — add filetype to `lua/custom/plugins/formatting.lua` (`formatters_by_ft`).
- **Extra lint** — add to `lua/custom/plugins/lint.lua` (`linters_by_ft`).
- **Treesitter** — add parser name to `lua/custom/plugins/tree-sitter.lua` (`parsers` table), then `:TSInstall <parser>`.

## Random / one-off languages

For a language you use once:

1. `:Mason` → install the LSP if listed.
2. Copy the template above into `lsp/<name>.lua` (check Mason docs for `cmd` and filetypes).
3. `:restart`.

Remove the file later if you do not need it; nothing else to clean up.

## Inspect running servers

```vim
:lsp
```

Or `:lua vim.print(vim.lsp.get_clients())`.
