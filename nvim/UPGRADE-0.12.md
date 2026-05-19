# Neovim 0.12 Upgrade — Changelog

All changes made to take advantage of Neovim 0.12 features.
Completion (`completion.lua`) was intentionally left unchanged.

---

## 1. Global Floating Window Borders (`options.lua`)

**Added:** `vim.opt.winborder = 'rounded'`

Neovim 0.12 introduces the `'winborder'` option which applies a border to **all** floating
windows by default — LSP hover, diagnostics floats, completion docs, etc. This replaces
the need to configure `border = 'rounded'` individually in every plugin and in
`vim.diagnostic.config`.

**What changed:** The `float = { border = 'rounded' }` field was removed from
`vim.diagnostic.config` since `winborder` handles it globally.

---

## 2. Native `lsp/` Directory for Server Configs

**Created:** `lsp/lua_ls.lua`, `lsp/clangd.lua`

Neovim 0.12 discovers LSP server configurations from `lsp/{name}.lua` files in the
runtimepath. When you call `vim.lsp.enable('lua_ls')`, Neovim automatically loads
`lsp/lua_ls.lua` and uses the returned table as the server config.

This replaces the old pattern of inline `vim.lsp.config('server', {...})` calls and
eliminates the need for `nvim-lspconfig` to provide base configurations.

Each file returns a `vim.lsp.Config` table with `cmd`, `filetypes`, `root_markers`,
and `settings`. To add a new server, create a new file in `lsp/` and add its name to the
`vim.lsp.enable` call.

---

## 3. LSP Plugin Cleanup (`lsp.lua`)

### Removed Plugins

| Plugin | Reason |
|--------|--------|
| `neovim/nvim-lspconfig` | Replaced by native `vim.lsp.config` + `vim.lsp.enable` + `lsp/` directory. Neovim 0.12 handles LSP server lifecycle natively. |
| `williamboman/mason-lspconfig.nvim` | Bridge between mason and lspconfig — no longer needed without lspconfig. |
| `j-hui/fidget.nvim` | Replaced by Neovim 0.12's built-in statusline which shows LSP progress natively. |

### Kept Plugins

| Plugin | Reason |
|--------|--------|
| `williamboman/mason.nvim` | Still needed for installing LSP servers, formatters, and linters. |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Auto-installs tools on startup. |
| `hrsh7th/cmp-nvim-lsp` | Provides LSP completion capabilities for nvim-cmp. |
| `folke/lazydev.nvim` | Provides Neovim Lua API types for lua_ls. |

### Other Changes in `lsp.lua`

- **Removed `clang-format` from `vim.lsp.enable`** — it's a formatter (used via conform.nvim),
  not an LSP server.
- **Removed the `get_fallback_flags()` function** — it was defined but never referenced.
- **Removed the `client_supports_method` wrapper** — the version check for nvim 0.10 vs older
  is unnecessary when targeting 0.12. Now calls `client:supports_method()` directly.
- **Simplified capabilities setup** — uses `require('cmp_nvim_lsp').default_capabilities()`
  directly instead of merging on top of `vim.lsp.protocol.make_client_capabilities()`.

---

## 4. Built-in Statusline (`ui.lua`)

**Removed:** `mini.statusline` setup from `mini.nvim` config.

Neovim 0.12 ships a default statusline that shows:
- File path and modified flag
- Diagnostics count (errors, warnings)
- LSP progress status (replaces fidget.nvim)
- Line/column position

`mini.ai` (enhanced text objects) is still configured and active.

If you prefer the old mini.statusline look, re-add to `ui.lua`:
```lua
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
```

---

## 5. Built-in Features You Get for Free

These Neovim 0.12 features require **no configuration** — they just work:

### Default LSP Keymaps
These are active whenever an LSP server attaches (your Lspsaga mappings take priority
where they overlap):

| Key | Action | Notes |
|-----|--------|-------|
| `grn` | `vim.lsp.buf.rename()` | Lspsaga `<leader>rn` overrides |
| `gra` | `vim.lsp.buf.code_action()` | Lspsaga `<leader>ca` overrides |
| `grr` | `vim.lsp.buf.references()` | Lspsaga `gr` overrides |
| `gri` | `vim.lsp.buf.implementation()` | Lspsaga `gI` overrides |
| `gO` | `vim.lsp.buf.document_symbol()` | New — works alongside Telescope `<leader>ds` |
| `<C-s>` (insert) | `vim.lsp.buf.signature_help()` | New — free signature help in insert mode |

### Treesitter Incremental Selection
In visual mode, `in` and `an` expand/shrink the selection to the next/previous treesitter
node boundary. Works alongside your existing treesitter-textobjects (`af`, `if`, `ac`, etc.).

### Other
- **`:restart`** — restart Neovim in-place, preserving your session
- **`:lsp`** — built-in command to inspect running LSP servers
- **No more "Press ENTER" prompts** — long messages no longer block

---

## Files Changed

| File | Change |
|------|--------|
| `lua/custom/options.lua` | Added `vim.opt.winborder = 'rounded'` |
| `lsp/lua_ls.lua` | **New** — native server config |
| `lsp/clangd.lua` | **New** — native server config |
| `lua/custom/plugins/lsp.lua` | Rewrote: removed nvim-lspconfig, mason-lspconfig, fidget; uses native LSP APIs |
| `lua/custom/plugins/ui.lua` | Removed mini.statusline (using built-in 0.12 statusline) |

## 6. Auto-Discovery of LSP Servers (`lsp.lua`)

`vim.lsp.enable` now auto-discovers all `lsp/*.lua` files instead of a hardcoded list.

**To add a new LSP server:**
1. Create `lsp/<name>.lua` returning a `vim.lsp.Config` table
2. Install the binary: `:MasonInstall <package-name>`
3. Restart Neovim (or `:restart`)

That's it — no need to edit `lsp.lua`. Example for adding Python support:

```lua
-- lsp/pyright.lua
---@type vim.lsp.Config
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', '.git' },
  settings = { python = { analysis = { typeCheckingMode = 'basic' } } },
}
```

Then `:MasonInstall pyright` and restart.

---

## 7. Clangd Stderr Noise Suppressed (`lsp/clangd.lua`)

Added `--log=error` to clangd's cmd flags. Clangd outputs verbose INFO messages on stderr,
which Neovim's LSP client logs as `[ERROR]`. With `--log=error`, only actual errors appear
in `lsp.log`.

---

## Files Unchanged (intentionally)

- `lua/custom/plugins/completion.lua` — per request
- All other plugin files — still provide value beyond what 0.12 offers natively
