-- nvim-surround - Add/change/delete surrounding delimiter pairs with ease
-- Examples: cs"' (change surrounding " to '), ds" (delete surrounding "), ys2w" (surround 2 words with ")
return {
  'kylechui/nvim-surround',
  version = '*',
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup {
      surrounds = {},
      aliases = {
        ['a'] = '>',
        ['b'] = ')',
        ['B'] = '}',
        ['r'] = ']',
        ['q'] = { '"', "'", '`' },
      },
      highlight = {
        duration = 200,
      },
      move_cursor = 'begin',
      indent_lines = function(start, stop)
        local b = vim.fn.getline(start)
        local a = vim.fn.getline(stop)
        return a:match '^%s*$' and b:match '^%s*$'
      end,
    }
  end,
}

