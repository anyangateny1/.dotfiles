return {
  'Mofiqul/vscode.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    vim.o.background = 'dark' -- or "light" for light theme

    local vscode = require 'vscode'
    vscode.setup {
      transparent = false, -- Enable if you want a transparent background
      italic_comments = true, -- Enable italic comments
      disable_nvimtree_bg = true, -- Prevent nvim-tree from changing its background
    }

    vscode.load()
  end,
}
