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
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'lua-language-server',
        'clangd',
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
        'markdownlint-cli2',
        'prettier',
        'eslint_d',
      },
    },
    config = function()
      require('mason').setup()

      require('mason-tool-installer').setup {
        ensure_installed = { 'lua-language-server', 'clangd', 'stylua', 'clang-format' },
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
    end,
  },
}
