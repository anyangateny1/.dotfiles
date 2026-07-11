---@type vim.lsp.Config
return {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--all-scopes-completion',
    '--completion-style=detailed',
    '--header-insertion=iwyu',
    '--pch-storage=memory',
    '--enable-config',
    '--function-arg-placeholders=true',
    '--query-driver=/usr/bin/g++*,/usr/bin/gcc*,/usr/bin/clang*',
  },
  filetypes = { 'c', 'cpp' },
  root_markers = { '.git', 'compile_commands.json', '.clangd' },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
