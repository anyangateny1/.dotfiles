return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'gomod',
        'gosum',
        'json',
        'yaml',
        'toml',
        'python',
        'javascript',
        'typescript',
        'css',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
        disable = { 'ruby', 'c', 'cpp' },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = { query = '@function.outer', desc = 'Around function' },
            ['if'] = { query = '@function.inner', desc = 'Inside function' },
            ['ac'] = { query = '@class.outer', desc = 'Around class' },
            ['ic'] = { query = '@class.inner', desc = 'Inside class' },
            ['aa'] = { query = '@parameter.outer', desc = 'Around argument' },
            ['ia'] = { query = '@parameter.inner', desc = 'Inside argument' },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']m'] = { query = '@function.outer', desc = 'Next function start' },
            [']]'] = { query = '@class.outer', desc = 'Next class start' },
          },
          goto_next_end = {
            [']M'] = { query = '@function.outer', desc = 'Next function end' },
            [']['] = { query = '@class.outer', desc = 'Next class end' },
          },
          goto_previous_start = {
            ['[m'] = { query = '@function.outer', desc = 'Prev function start' },
            ['[['] = { query = '@class.outer', desc = 'Prev class start' },
          },
          goto_previous_end = {
            ['[M'] = { query = '@function.outer', desc = 'Prev function end' },
            ['[]'] = { query = '@class.outer', desc = 'Prev class end' },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = { query = '@parameter.inner', desc = 'Swap with next argument' },
          },
          swap_previous = {
            ['<leader>A'] = { query = '@parameter.inner', desc = 'Swap with previous argument' },
          },
        },
      },
    },
  },
}
