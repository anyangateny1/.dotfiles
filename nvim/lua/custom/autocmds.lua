-- Autocommands

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Remove trailing whitespace from C/C++ files before save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.cpp', '*.h', '*.hpp', '*.c', '*.cc', '*.cxx' },
  group = vim.api.nvim_create_augroup('cpp-trailing-whitespace', { clear = true }),
  callback = function()
    local save_cursor = vim.fn.getpos '.'
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.setpos('.', save_cursor)
  end,
  desc = 'Remove trailing whitespace from C/C++ files before save',
})

-- C/C++ indentation settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  group = vim.api.nvim_create_augroup('cpp-indent', { clear = true }),
  callback = function()
    vim.opt_local.cindent = true
    vim.opt_local.smartindent = false
    vim.opt_local.autoindent = true
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
  desc = 'C-style indentation for C/C++ files',
})
