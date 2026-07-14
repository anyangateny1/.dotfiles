-- Autocommands

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Trim trailing whitespace before save (toggle with vim.g.trim_whitespace)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('trim-whitespace', { clear = true }),
  callback = function()
    if not vim.g.trim_whitespace then
      return
    end
    local pos = vim.fn.getpos '.'
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.setpos('.', pos)
  end,
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

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text' },
  callback = function()
    vim.opt_local.textwidth = 80
  end,
})

-- Spell only in prose-like buffers (toggle anytime with <leader>ts)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('spell-prose', { clear = true }),
  pattern = { 'markdown', 'text', 'gitcommit', 'gitrebase' },
  callback = function()
    vim.opt_local.spell = true
  end,
})
