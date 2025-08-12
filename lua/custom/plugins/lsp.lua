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
          
          -- Only set keymaps that DON'T conflict with LSP Saga
          -- LSP Saga will handle: gd, gD, gr, gt, gT, K, <leader>ca
          
          -- These are safe to keep as they use telescope and don't conflict
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          
          -- Keep these specific clangd keymaps that LSP Saga doesn't override
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == 'clangd' then
            map('<leader>ch', vim.lsp.buf.declaration, '[C]langd [H]eader declaration')
            map('<leader>cI', function()
              vim.cmd('Telescope lsp_incoming_calls')
            end, '[C]langd [I]nclude hierarchy')
          end
          
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client.supports_method and client:supports_method(method, { bufnr = bufnr })
            elseif vim.fn.has 'nvim-0.10' == 1 then
              return client.supports_method and client:supports_method(method, { bufnr = bufnr })
            else
              return client.server_capabilities and client.server_capabilities[method] ~= nil
            end
          end
          
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
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Helper function to get appropriate flags based on file type
      local function get_fallback_flags(filetype)
        local base_flags = {
          -- C++ standard library paths
          '-I/usr/include/c++/13',
          '-I/usr/include/x86_64-linux-gnu/c++/13',
          '-I/usr/include/c++/13/backward',
          -- System headers
          '-I/usr/include',
          '-I/usr/include/x86_64-linux-gnu',
          '-I/usr/local/include',
          -- Additional paths
          '-I/usr/lib/x86_64-linux-gnu/openmpi/include',
          -- Standard defines
          '-D__STDC_CONSTANT_MACROS',
          '-D__STDC_FORMAT_MACROS',
          '-D__STDC_LIMIT_MACROS',
        }

        if filetype == 'c' then
          table.insert(base_flags, '-std=gnu11')
        elseif filetype == 'cpp' then
          table.insert(base_flags, '-std=c++20')
        end

        return base_flags
      end

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
          },
          on_new_config = function(new_config, new_root_dir)
            local filetype = vim.bo.filetype
            new_config.init_options.fallbackFlags = get_fallback_flags(filetype)
          end,
          on_attach = function(client, bufnr)
            -- Set environment variables
            vim.env.C_INCLUDE_PATH = '/usr/include:/usr/local/include:/usr/include/x86_64-linux-gnu'
            vim.env.CPLUS_INCLUDE_PATH = '/usr/include/c++/13:/usr/include/x86_64-linux-gnu/c++/13:/usr/include/c++/13/backward:/usr/include:/usr/include/x86_64-linux-gnu'
            vim.env.LD_LIBRARY_PATH = '/usr/lib/x86_64-linux-gnu:/usr/local/lib'
          end,
        },
      }

      for server_name, server_config in pairs(servers) do
        server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
        require('lspconfig')[server_name].setup(server_config)
      end

      require('mason-tool-installer').setup {
        ensure_installed = { 'lua_ls', 'clangd', 'stylua', 'clang-format' },
      }
    end,
  },
}

