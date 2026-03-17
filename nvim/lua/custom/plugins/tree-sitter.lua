local parsers = {
  'bash',
  'c',
  'cpp',
  'css',
  'diff',
  'go',
  'gomod',
  'gosum',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

local indent_disabled = { ruby = true, c = true, cpp = true }

return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      vim.defer_fn(function()
        require('nvim-treesitter').install(parsers)
      end, 0)

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            if not indent_disabled[ev.match] then
              vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true },
        move = { set_jumps = true },
      }

      local select_ts = function(key, query, desc)
        vim.keymap.set({ 'x', 'o' }, key, function()
          require('nvim-treesitter-textobjects.select').select_textobject(query, 'textobjects')
        end, { desc = desc })
      end
      select_ts('af', '@function.outer', 'Around function')
      select_ts('if', '@function.inner', 'Inside function')
      select_ts('ac', '@class.outer', 'Around class')
      select_ts('ic', '@class.inner', 'Inside class')
      select_ts('aa', '@parameter.outer', 'Around argument')
      select_ts('ia', '@parameter.inner', 'Inside argument')

      local move = require 'nvim-treesitter-textobjects.move'
      local move_map = function(key, fn, query, desc)
        vim.keymap.set({ 'n', 'x', 'o' }, key, function()
          fn(query, 'textobjects')
        end, { desc = desc })
      end
      move_map(']m', move.goto_next_start, '@function.outer', 'Next function start')
      move_map(']]', move.goto_next_start, '@class.outer', 'Next class start')
      move_map(']M', move.goto_next_end, '@function.outer', 'Next function end')
      move_map('][', move.goto_next_end, '@class.outer', 'Next class end')
      move_map('[m', move.goto_previous_start, '@function.outer', 'Prev function start')
      move_map('[[', move.goto_previous_start, '@class.outer', 'Prev class start')
      move_map('[M', move.goto_previous_end, '@function.outer', 'Prev function end')
      move_map('[]', move.goto_previous_end, '@class.outer', 'Prev class end')

      vim.keymap.set('n', '<leader>a', function()
        require('nvim-treesitter-textobjects.swap').swap_next '@parameter.inner'
      end, { desc = 'Swap with next argument' })
      vim.keymap.set('n', '<leader>A', function()
        require('nvim-treesitter-textobjects.swap').swap_previous '@parameter.inner'
      end, { desc = 'Swap with previous argument' })
    end,
  },
}
