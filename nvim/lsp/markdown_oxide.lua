---@type vim.lsp.Config
-- Drop a .markdownoxide.toml in any non-Obsidian notes root to opt-in.
return {
  cmd = { 'markdown-oxide' },
  filetypes = { 'markdown' },
  root_markers = { '.obsidian', '.markdownoxide.toml' },
}
