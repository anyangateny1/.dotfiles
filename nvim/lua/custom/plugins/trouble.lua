return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    icons = {
      indent = {
        fold_open = '',
        fold_closed = '',
      },
    },

    modes = {
      doc_diagnostics = {
        mode = 'diagnostics',
        filter = { buf = 0 },
        preview = { type = 'float', relative = 'editor' },
        win = { position = 'bottom', size = 10 },
      },
      diagnostics = {
        preview = { type = 'float', relative = 'editor' },
        win = { position = 'bottom', size = 10 },
      },
      qflist = {
        preview = { type = 'float', relative = 'editor' },
        win = { position = 'bottom', size = 10 },
      },
      loclist = {
        preview = { type = 'float', relative = 'editor' },
        win = { position = 'bottom', size = 10 },
      },
      lsp_references = {
        preview = { type = 'float', relative = 'editor' },
        win = { position = 'bottom', size = 10 },
        auto_jump = true,
      },
    },
  },

  config = function(_, opts)
    require('trouble').setup(opts)

    vim.keymap.set('n', '<leader>xx', function()
      require('trouble').toggle('diagnostics')
    end, { desc = 'Toggle Trouble' })

    vim.keymap.set('n', '<leader>xw', function()
      require('trouble').toggle('diagnostics')
    end, { desc = 'Workspace Diagnostics' })

    vim.keymap.set('n', '<leader>xd', function()
      require('trouble').toggle('doc_diagnostics')
    end, { desc = 'Document Diagnostics' })

    vim.keymap.set('n', '<leader>xq', function()
      require('trouble').toggle('qflist')
    end, { desc = 'Quickfix List' })

    vim.keymap.set('n', '<leader>xl', function()
      require('trouble').toggle('loclist')
    end, { desc = 'Location List' })

    vim.keymap.set('n', 'gR', function()
      require('trouble').toggle('lsp_references')
    end, { desc = 'LSP References' })

    vim.keymap.set('n', '[t', function()
      if require('trouble').is_open() then
        require('trouble').prev({ jump = true })
      else
        pcall(vim.cmd.cprev)
      end
    end, { desc = 'Previous trouble/quickfix item' })

    vim.keymap.set('n', ']t', function()
      if require('trouble').is_open() then
        require('trouble').next({ jump = true })
      else
        pcall(vim.cmd.cnext)
      end
    end, { desc = 'Next trouble/quickfix item' })
  end,
}

