return {
  'tpope/vim-fugitive',
  config = function()
    -- Optional: Add any fugitive-specific configuration here
    -- For example, you could map a shortcut for Git status:
    vim.api.nvim_set_keymap('n', '<leader>gs', ':Git status<CR>', { noremap = true, silent = true })
  end,
}
