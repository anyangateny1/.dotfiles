return {
  -- Highlight todo, notes in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      highlight = {
        pattern = [[.*<(KEYWORDS)\s*%(\([^)]*\))?\s*:]],
      },
      search = {
        pattern = [[\b(KEYWORDS)\s*(\([^)]*\))?\s*:]],
      },
    },
  },

  -- Mini plugins collection (mini.statusline; LSP progress also via fidget.nvim)
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}
