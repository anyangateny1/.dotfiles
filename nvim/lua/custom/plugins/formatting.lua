local clang_style_files = { '.clang-format', '_clang-format', 'clang-format.yaml' }

local function home_clang_style()
  local path = vim.fs.normalize(vim.fn.expand '~/.clang-format')
  return vim.fn.filereadable(path) == 1 and path or nil
end

local function find_clang_style(path)
  return vim.fs.find(clang_style_files, {
    path = path,
    upward = true,
  })[1] or home_clang_style()
end

local function clang_style_arg(path)
  local style_file = find_clang_style(path)
  return style_file and ('-style=file:' .. style_file) or '-style=file'
end

local function has_clang_style(bufnr)
  return find_clang_style(vim.api.nvim_buf_get_name(bufnr)) ~= nil
end

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },

  keys = {
    {
      '<leader>f',
      function()
        local ft = vim.bo.filetype

        if (ft == 'c' or ft == 'cpp') and not has_clang_style(0) then
          vim.notify('clang-format: no style file found — skipping format', vim.log.levels.WARN)
          return
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
      '<leader>cf',
      '<cmd>ConformInfo<cr>',
      desc = '[C]onform In[f]o',
    },
  },

  opts = {
    notify_on_error = false,

    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype

      if (ft == 'c' or ft == 'cpp') and not has_clang_style(bufnr) then
        return nil
      end

      return {
        timeout_ms = 500,
        lsp_format = 'never',
      }
    end,

    formatters_by_ft = {
      lua = { 'stylua' },
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },
    },

    formatters = {
      ['clang-format'] = {
        condition = function(_, ctx)
          return find_clang_style(ctx.filename) ~= nil
        end,
        cwd = function(_, ctx)
          local style_file = find_clang_style(ctx.filename)
          return style_file and vim.fs.dirname(style_file) or nil
        end,
        prepend_args = function(_, ctx)
          return { clang_style_arg(ctx.filename) }
        end,
      },
      ruff_format = {},
      ruff_fix = {},
      ruff_organize_imports = {},
    },
  },
}
