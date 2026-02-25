return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },

  keys = {
    {
      '<leader>f',
      function()
        local bufname = vim.api.nvim_buf_get_name(0)

        if vim.bo.filetype == 'cpp' or vim.bo.filetype == 'c' then
          local style_file = vim.fs.find({ 'clang-format.yaml', '.clang-format', '_clang-format' }, { path = bufname, upward = true })[1]

          if not style_file then
            vim.notify('clang-format: no style file found — skipping format', vim.log.levels.WARN)
            return
          end
        end

        require('conform').format {
          async = true,
          lsp_format = 'never',
        }
      end,
      mode = { 'n', 'v' },
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
      local ft = vim.bo[bufnr].filetype

      -- 🚫 skip C/C++ if no style file
      if ft == 'c' or ft == 'cpp' then
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local style_file = vim.fs.find({ 'clang-format.yaml', '.clang-format', '_clang-format' }, { path = filename, upward = true })[1]

        if not style_file then
          return nil
        end
      end

      return {
        timeout_ms = 500,
        lsp_format = 'never',
      }
    end,

    formatters_by_ft = {
      lua = { 'stylua' },
      cpp = { 'clang-format' },
      c = { 'clang-format' },
    },

    formatters = {
      ['clang-format'] = {
        condition = function(_, ctx)
          local style_file = vim.fs.find({ 'clang-format.yaml', '.clang-format', '_clang-format' }, { path = ctx.filename, upward = true })[1]
          return style_file ~= nil
        end,

        cwd = function(_, ctx)
          local style_file = vim.fs.find({ 'clang-format.yaml', '.clang-format', '_clang-format' }, { path = ctx.filename, upward = true })[1]
          if style_file then
            return vim.fn.fnamemodify(style_file, ':h')
          end
        end,

        args = function(_, ctx)
          local style_file = vim.fs.find({ 'clang-format.yaml', '.clang-format', '_clang-format' }, { path = ctx.filename, upward = true })[1]
          return { '-style=file:' .. style_file }
        end,
      },
    },
  },
}
