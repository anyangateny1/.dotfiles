-- ═══════════════════════════════════════════════════════════════════════════
--  Linting — nvim-lint
-- ═══════════════════════════════════════════════════════════════════════════
--
--  Adding a linter
--    1. Add the Mason package name to ensure_installed in lsp.lua.
--    2. Add  filetype = { 'tool-name' }  to linters_by_ft below.
--    Linting runs automatically on BufEnter, BufWritePost, and InsertLeave.
--
--  Skip this file if the LSP already provides diagnostics:
--    lua_ls, clangd (--clang-tidy), gopls (staticcheck) → not listed here.
--    pyright covers types; ruff fills in style/correctness for Python.
--    JS/TS: handled by the eslint or biome LSP (see lsp/) → not listed here.
--
-- ═══════════════════════════════════════════════════════════════════════════

return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      -- ruff: style, correctness, and complexity (pyright handles types separately)
      python   = { 'ruff' },
      -- markdownlint-cli2: prose linting (link validity, heading structure, etc.)
      markdown = { 'markdownlint-cli2' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Only lint modifiable buffers (skip LSP hover docs, help pages, etc.)
        if vim.bo.modifiable then
          lint.try_lint(nil, { ignore_errors = true })
        end
      end,
    })
  end,
}
