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
      desc = '[C]onform [I]nfo - Debug formatter info',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = {}
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      cpp = { 'clang-format' },
    },
    formatters = {
      ['clang-format'] = {
        -- Ensure clang-format uses the directory containing .clang-format as working directory
        cwd = function(self, ctx)
          local style_file = vim.fs.find('.clang-format', {
            path = ctx.filename,
            upward = true,
          })[1]
          
          local working_dir
          if style_file then
            -- Use the directory containing the .clang-format file
            working_dir = vim.fn.fnamemodify(style_file, ':h')
          else
            -- Fallback to current file's directory
            working_dir = vim.fn.fnamemodify(ctx.filename, ':h')
          end
          
          -- Log the working directory
          print("🔧 clang-format working directory: " .. working_dir)
          return working_dir
        end,
        -- Explicitly specify the style file
        args = function(self, ctx)
          local style_file = vim.fs.find('.clang-format', {
            path = ctx.filename,
            upward = true,
          })[1]
          
          local args
          if style_file then
            args = { '-style=file:' .. style_file }
            print("🎨 Using .clang-format file: " .. style_file)
          else
            args = { '-style=file' }
            print("⚠️  No .clang-format found, using default style search")
          end
          
          -- Log the full command that will be executed
          print("📝 clang-format args: " .. table.concat(args, " "))
          return args
        end,
      },
    },
  },
} 