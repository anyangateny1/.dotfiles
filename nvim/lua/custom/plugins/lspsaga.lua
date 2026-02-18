return {
  'nvimdev/lspsaga.nvim',
  event = 'LspAttach',
  config = function()
    require('lspsaga').setup({
      ui = {
        winblend = 10,
        border = 'rounded',
        colors = {
          normal_bg = '#002b36',
        },
      },
      lightbulb = {
        enable = false,
        sign = false,
        virtual_text = true,
      },
      symbol_in_winbar = {
        enable = true,
        separator = ' › ',
        hide_keyword = false,
        show_file = true,
        folder_level = 1,
        color_mode = true,
      },
      code_action = {
        num_shortcut = true,
        show_server_name = false,
        extend_gitsigns = true,
        keys = {
          quit = 'q',
          exec = '<CR>',
        },
      },
      definition = {
        edit = '<C-c>o',
        vsplit = '<C-c>v',
        split = '<C-c>i',
        tabe = '<C-c>t',
        quit = 'q',
      },
      diagnostic = {
        show_code_action = true,
        show_source = true,
        jump_num_shortcut = true,
        max_width = 0.7,
        text_hl_follow = false,
        border_follow = true,
        keys = {
          exec_action = 'o',
          quit = 'q',
        },
      },
      rename = {
        quit = '<C-c>',
        exec = '<CR>',
        mark = 'x',
        confirm = '<CR>',
        in_select = true,
      },
      outline = {
        win_position = 'right',
        win_width = 30,
        show_detail = true,
        auto_preview = true,
        auto_refresh = true,
        auto_close = true,
        keys = {
          jump = 'o',
          expand_collapse = 'u',
          quit = 'q',
        },
      },
      finder = {
        edit = { 'o', '<CR>' },
        vsplit = 's',
        split = 'i',
        tabe = 't',
        quit = { 'q', '<ESC>' },
      },
      hover = {
        max_width = 0.9,
        max_height = 0.8,
        open_link = 'gx',
        open_browser = '!chrome',
      },
    })

    -- LSP Saga keymaps (these take priority over base LSP)
    local keymap = vim.keymap.set

    -- Core LSP functionality (standard motions)
    keymap('n', 'gh', '<cmd>Lspsaga finder<CR>', { desc = 'LSP: Find symbol (def/ref/impl)' })
    keymap({ 'n', 'v' }, '<leader>ca', '<cmd>Lspsaga code_action<CR>', { desc = 'LSP: Code actions' })
    keymap('n', '<leader>rn', '<cmd>Lspsaga rename<CR>', { desc = 'LSP: Rename symbol' })
    
    -- Definition and type definition
    keymap('n', 'gd', '<cmd>Lspsaga goto_definition<CR>', { desc = 'LSP: Goto definition' })
    keymap('n', 'gD', vim.lsp.buf.declaration, { desc = 'LSP: Goto declaration' })
    keymap('n', 'gt', '<cmd>Lspsaga peek_type_definition<CR>', { desc = 'LSP: Peek type definition' })
    keymap('n', 'gT', '<cmd>Lspsaga goto_type_definition<CR>', { desc = 'LSP: Goto type definition' })
    keymap('n', '<leader>D', vim.lsp.buf.type_definition, { desc = 'LSP: Type definition' })

    -- Hover documentation
    keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { desc = 'LSP: Hover documentation' })
    keymap('n', '<leader>K', '<cmd>Lspsaga hover_doc ++keep<CR>', { desc = 'LSP: Pin hover documentation' })

    -- References and implementations
    keymap('n', 'gr', vim.lsp.buf.references, { desc = 'LSP: References' })
    keymap('n', 'gI', vim.lsp.buf.implementation, { desc = 'LSP: Goto implementation' })

    -- Diagnostics
    keymap('n', '<leader>sl', '<cmd>Lspsaga show_line_diagnostics<CR>', { desc = 'LSP: Show line diagnostics' })
    keymap('n', '<leader>sb', '<cmd>Lspsaga show_buf_diagnostics<CR>', { desc = 'LSP: Show buffer diagnostics' })
    keymap('n', '<leader>sW', '<cmd>Lspsaga show_workspace_diagnostics<CR>', { desc = 'LSP: Show workspace diagnostics' })
    keymap('n', '<leader>sc', '<cmd>Lspsaga show_cursor_diagnostics<CR>', { desc = 'LSP: Show cursor diagnostics' })

    -- Diagnostic navigation
    keymap('n', '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', { desc = 'LSP: Previous diagnostic' })
    keymap('n', ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', { desc = 'LSP: Next diagnostic' })
    keymap('n', '[E', function()
      require('lspsaga.diagnostic'):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, { desc = 'LSP: Previous error' })
    keymap('n', ']E', function()
      require('lspsaga.diagnostic'):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, { desc = 'LSP: Next error' })

    -- Call hierarchy
    keymap('n', '<Leader>ci', '<cmd>Lspsaga incoming_calls<CR>', { desc = 'LSP: Incoming calls' })
    keymap('n', '<Leader>co', '<cmd>Lspsaga outgoing_calls<CR>', { desc = 'LSP: Outgoing calls' })

    -- Outline
    keymap('n', '<leader>o', '<cmd>Lspsaga outline<CR>', { desc = 'LSP: Toggle outline' })

    -- Terminal
    keymap({ 'n', 't' }, '<A-d>', '<cmd>Lspsaga term_toggle<CR>', { desc = 'Toggle floating terminal' })

  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
} 