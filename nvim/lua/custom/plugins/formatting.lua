return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>ci',
      '<cmd>ConformInfo<cr>',
      desc = '[C]onform [I]nfo',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = {}
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      cpp = { 'clang-format' },
    },
    formatters = {
      ['clang-format'] = {
        cwd = function(_, ctx)
          local style_file = vim.fs.find('.clang-format', {
            path = ctx.filename,
            upward = true,
          })[1]
          if style_file then
            return vim.fn.fnamemodify(style_file, ':h')
          end
          return vim.fn.fnamemodify(ctx.filename, ':h')
        end,
        args = function(_, ctx)
          local style_file = vim.fs.find('.clang-format', {
            path = ctx.filename,
            upward = true,
          })[1]
          if style_file then
            return { '-style=file:' .. style_file }
          end
          return { '-style=file' }
        end,
      },
    },
  },
}
