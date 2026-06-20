---@type vim.lsp.Config
return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  -- css-lsp crashes with "Cannot read properties of null (reading 'validProperties')"
  -- when settings are absent. These must be provided explicitly.
  settings = {
    css  = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
}
