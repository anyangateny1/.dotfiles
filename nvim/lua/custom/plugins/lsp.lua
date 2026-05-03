return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'williamboman/mason.nvim',
    dependencies = {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'hrsh7th/cmp-nvim-lsp',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      require('mason').setup()

      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua-language-server',
          'clangd',
          'gopls',
          'pyright',
          'markdown-oxide',
          'typescript-language-server',
          'eslint-lsp',
          'tailwindcss-language-server',
          'css-lsp',
          'html-lsp',
          'json-lsp',
          'emmet-language-server',
          'stylua',
          'clang-format',
          'ruff',
          'gofumpt',
          'goimports',
          'markdownlint-cli2',
          'prettier',
          'eslint_d',
        },
      }

      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      -- Auto-discover all servers from the lsp/ directory.
      -- To add a new server: create lsp/<name>.lua and :MasonInstall <package>.
      local lsp_dir = vim.fn.stdpath 'config' .. '/lsp'
      local servers = {}
      for name, type in vim.fs.dir(lsp_dir) do
        if type == 'file' and name:match '%.lua$' then
          table.insert(servers, (name:gsub('%.lua$', '')))
        end
      end
      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.name == 'clangd' then
            local function switch_source_header()
              local bufnr = event.buf
              local clangd_clients = vim.lsp.get_clients { bufnr = bufnr, name = 'clangd' }
              if #clangd_clients > 0 then
                local params = { uri = vim.uri_from_bufnr(bufnr) }
                clangd_clients[1]:request('textDocument/switchSourceHeader', params, function(err, result)
                  if err then
                    vim.notify('clangd switchSourceHeader error: ' .. (err.message or tostring(err)), vim.log.levels.WARN)
                    return
                  end
                  if not result or result == '' then
                    vim.notify('No corresponding source/header found', vim.log.levels.INFO)
                    return
                  end
                  vim.cmd('edit ' .. vim.uri_to_fname(result))
                end, bufnr)
                return
              end
              -- Fallback heuristic when clangd cannot resolve header/source
              local fname = vim.api.nvim_buf_get_name(bufnr)
              local stem, ext = fname:match '^(.*)%.([%w]+)$'
              if not stem then
                return
              end
              local src_exts = { 'c', 'cc', 'cpp', 'cxx' }
              local hdr_exts = { 'h', 'hh', 'hpp', 'hxx' }
              local function contains(t, v)
                for _, x in ipairs(t) do
                  if x == v then
                    return true
                  end
                end
                return false
              end
              local function first_existing(candidates)
                for _, e in ipairs(candidates) do
                  local p = stem .. '.' .. e
                  if (vim.uv or vim.loop).fs_stat(p) then
                    return p
                  end
                end
              end
              local target
              if contains(src_exts, ext) then
                target = first_existing(hdr_exts)
              else
                target = first_existing(src_exts)
              end
              if target then
                vim.cmd('edit ' .. target)
              else
                vim.notify('No corresponding source/header found', vim.log.levels.INFO)
              end
            end
            map('<leader>ch', switch_source_header, '[C]langd Switch header/source')
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
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

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { source = 'if_many' },
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
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Apply cmp-nvim-lsp capabilities to all servers via wildcard
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      local function get_fallback_flags(filetype)
        local base_flags = {
          '-D__STDC_CONSTANT_MACROS',
          '-D__STDC_FORMAT_MACROS',
          '-D__STDC_LIMIT_MACROS',
        }

        if vim.fn.has 'mac' == 1 then
          local sdk = vim.trim(vim.fn.system 'xcrun --show-sdk-path 2>/dev/null')
          if sdk ~= '' then
            table.insert(base_flags, '-isysroot')
            table.insert(base_flags, sdk)
          end
          vim.list_extend(base_flags, {
            '-I/usr/local/include',
            '-I/opt/homebrew/include',
          })
        else
          vim.list_extend(base_flags, {
            '-I/usr/include/c++/14',
            '-I/usr/include/x86_64-linux-gnu/c++/14',
            '-I/usr/include/c++/14/backward',
            '-I/usr/include',
            '-I/usr/include/x86_64-linux-gnu',
            '-I/usr/local/include',
          })
        end

        if filetype == 'c' then
          table.insert(base_flags, '-std=gnu11')
        elseif filetype == 'cpp' then
          table.insert(base_flags, '-std=c++23')
        end

        return base_flags
      end

      -- Server-specific overrides (merged on top of '*' defaults and lspconfig defaults)
      vim.lsp.config('lua-language-server', {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      })

      vim.lsp.config('clangd', {
        cmd = {
          'clangd',
          '--compile-commands-dir=build', -- points to your compile_commands.json
          '--background-index',
          '--clang-tidy',
          '--all-scopes-completion',
          '--completion-style=detailed',
          '--header-insertion=iwyu',
          '--function-arg-placeholders=true',
          '--pch-storage=memory',
          '--enable-config',
          '--query-driver=/usr/bin/g++*', -- note the * wildcard to match GCC versions
        },
        filetypes = { 'c', 'cpp', 'hpp', 'h' },
        root_markers = { '.git', 'compile_commands.json', '.clangd' },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- Enable LSP servers
      vim.lsp.enable { 'lua-language-server', 'clangd', 'stylua', 'clang-format', 'pyright', 'mesonlsp' }

      require('mason-tool-installer').setup {
        ensure_installed = { 'lua-language-server', 'clangd', 'stylua', 'clang-format', 'pyright', 'mesonlsp' },
      }
    end,
  },
}
