---@type vim.lsp.Config
return {
  cmd = {
    'clangd',
    '--log=error',
    '--compile-commands-dir=build',
    '--background-index',
    '--clang-tidy',
    '--all-scopes-completion',
    '--completion-style=detailed',
    '--header-insertion=iwyu',
    '--function-arg-placeholders',
    '--pch-storage=memory',
    '--enable-config',
    '--query-driver=/usr/bin/g++*',
  },
  filetypes = { 'c', 'cpp' },
  root_markers = { '.git', 'compile_commands.json', '.clangd' },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
