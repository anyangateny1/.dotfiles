return {
  -- LSP Configuration for Lua development
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  -- Main LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          -- Note: Neovim 0.11.3 adds many default LSP keymaps:
          -- grn = vim.lsp.buf.rename, grr = vim.lsp.buf.references, gri = vim.lsp.buf.implementation
          -- gra = vim.lsp.buf.code_action, gO = vim.lsp.buf.document_symbol, CTRL-S = vim.lsp.buf.signature_help
          -- [d, ]d = navigate diagnostics. You can rely on these defaults or override them below.
          
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client.supports_method and client:supports_method(method, { bufnr = bufnr })
            elseif vim.fn.has 'nvim-0.10' == 1 then
              return client.supports_method and client:supports_method(method, { bufnr = bufnr })
            else
              -- Fallback for older versions
              return client.server_capabilities and client.server_capabilities[method] ~= nil
            end
          end
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
        -- New in Neovim 0.11: Virtual lines (uncomment to enable)
        -- virtual_lines = { current_line = true }, -- Shows diagnostics as virtual lines below current line
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Simple server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
        clangd = {
          cmd = { 
            'clangd', 
            '--compile-commands-dir=build',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
            '--clang-tidy',
            '--all-scopes-completion',
            '--cross-file-rename',
            '--log=info',
            '--background-index',
            '--pch-storage=memory',
            '--enable-config',
            '--header-insertion-decorators',
            '--suggest-missing-includes',
            '--query-driver=/usr/bin/g++,/usr/bin/gcc,/usr/bin/clang++,/usr/bin/clang',
          },
          filetypes = { 'c', 'cpp' },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
            fallbackFlags = {
              -- C++ standard library paths
              '-I/usr/include/c++/13',
              '-I/usr/include/x86_64-linux-gnu/c++/13',
              '-I/usr/include/c++/13/backward',
              -- System headers
              '-I/usr/include',
              '-I/usr/include/x86_64-linux-gnu',
              '-I/usr/local/include',
              -- Additional paths for completeness
              '-I/usr/lib/x86_64-linux-gnu/openmpi/include',
              -- Standard defines
              '-D__STDC_CONSTANT_MACROS',
              '-D__STDC_FORMAT_MACROS',
              '-D__STDC_LIMIT_MACROS',
              -- C++ standard
              '-std=c++20',
            },
          },
          on_attach = function(client, bufnr)
            -- Set environment variables for additional header discovery
            vim.env.C_INCLUDE_PATH = '/usr/include:/usr/local/include:/usr/include/x86_64-linux-gnu'
            vim.env.CPLUS_INCLUDE_PATH = '/usr/include/c++/13:/usr/include/x86_64-linux-gnu/c++/13:/usr/include/c++/13/backward:/usr/include:/usr/include/x86_64-linux-gnu'
            vim.env.LD_LIBRARY_PATH = '/usr/lib/x86_64-linux-gnu:/usr/local/lib'
            
            -- Enhanced keymap to go to header file declaration (like VSCode)
            vim.keymap.set('n', '<leader>ch', function()
              -- Use LSP to go to declaration (header file)
              vim.lsp.buf.declaration()
            end, { desc = 'Go to header declaration', buffer = bufnr })
            
            -- Alternative keymap for type definition (shows the actual type in headers)
            vim.keymap.set('n', '<leader>ct', function()
              vim.lsp.buf.type_definition()
            end, { desc = 'Go to type definition', buffer = bufnr })
            
            -- Quick keymap to show include hierarchy
            vim.keymap.set('n', '<leader>cI', function()
              vim.cmd('Telescope lsp_incoming_calls')
            end, { desc = 'Show include hierarchy', buffer = bufnr })
          end,
        },
      }

      -- Setup LSP servers manually to avoid automatic_enable issues
      for server_name, server_config in pairs(servers) do
        server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
        require('lspconfig')[server_name].setup(server_config)
      end

      -- Setup tool installer separately
      require('mason-tool-installer').setup {
        ensure_installed = { 'lua_ls', 'clangd', 'stylua', 'clang-format' },
      }
    end,
  },
} 