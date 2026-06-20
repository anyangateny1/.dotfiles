---@type vim.lsp.Config
-- Biome: fast Rust-based linter + formatter for JS/TS/JSON/CSS.
-- Only starts when a biome.json or biome.jsonc exists in the project root.
-- Projects using ESLint configs get lsp/eslint.lua instead — both are opt-in.
return {
  cmd = { 'biome', 'lsp-proxy' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'json',
    'jsonc',
    'css',
  },
  root_markers = { 'biome.json', 'biome.jsonc' },
  workspace_required = true,
}
