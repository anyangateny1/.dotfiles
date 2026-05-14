---@type vim.lsp.Config
return {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  -- Only start when an explicit ESLint config exists; 'package.json' and '.git'
  -- alone are too broad and cause the server to receive undefined for workingDir.
  root_markers = {
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.cjs',
    'eslint.config.ts',
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.cjs',
    '.eslintrc.json',
    '.eslintrc.yaml',
    '.eslintrc.yml',
  },
  -- Prevent starting when no root can be resolved (avoids undefined path error).
  workspace_required = true,
  settings = {
    eslint = {
      -- Let the server figure out cwd per-file rather than assuming a fixed root.
      workingDirectory = { mode = 'auto' },
    },
  },
}
