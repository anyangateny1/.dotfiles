---@type vim.lsp.Config
return {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'scss',
    'javascriptreact',
    'typescriptreact',
  },
  root_markers = { 'package.json', '.git' },
}
