-- ═══════════════════════════════════════════════════════════════════════════
--  LSP + Mason
-- ═══════════════════════════════════════════════════════════════════════════
--
--  Adding a language server
--    1. Create  lsp/<server-name>.lua  (copy an existing one as a template).
--       Set cmd, filetypes, root_markers, and optionally settings/init_options.
--    2. Add the Mason package name to ensure_installed below.
--    The lsp/ directory is auto-scanned at startup; no further wiring needed.
--
--  Adding a formatter  →  see lua/custom/plugins/formatting.lua
--  Adding a linter     →  see lua/custom/plugins/lint.lua
--
-- ═══════════════════════════════════════════════════════════════════════════

return {
  -- Neovim Lua API completions (lazydev replaces the old lua_ls library hack)
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

      -- All tools managed by Mason live here.
      -- Add new package names when extending LSP, formatting, or linting.
      require('mason-tool-installer').setup {
        ensure_installed = {
          -- LSP servers
          'lua-language-server',
          'clangd',
          'pyright',
          'markdown-oxide',
          'json-lsp',
          'biome',
          'bash-language-server',
          'yaml-language-server',

          -- Formatters  (see formatting.lua)
          'stylua',
          'clang-format',
          'ruff',

          -- Linters  (see lint.lua)
          'markdownlint-cli2',
        },
      }

      -- Attach cmp-nvim-lsp capabilities to every server globally.
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      -- Auto-discover servers: every lsp/<name>.lua becomes an enabled server.
      local lsp_dir = vim.fn.stdpath 'config' .. '/lsp'
      local servers = {}
      for name, type in vim.fs.dir(lsp_dir) do
        if type == 'file' and name:match '%.lua$' then
          table.insert(servers, (name:gsub('%.lua$', '')))
        end
      end
      vim.lsp.enable(servers)

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- clangd: switch between header and source via the LSP request.
          if client and client.name == 'clangd' then
            map('<leader>ch', function()
              local bufnr = event.buf
              local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'clangd' }
              if #clients == 0 then
                return
              end

              clients[1]:request('textDocument/switchSourceHeader', { uri = vim.uri_from_bufnr(bufnr) }, function(err, result)
                if err then
                  vim.notify('clangd: ' .. (err.message or tostring(err)), vim.log.levels.WARN)
                  return
                end
                if not result or result == '' then
                  vim.notify('No corresponding source/header found', vim.log.levels.INFO)
                  return
                end
                vim.cmd('edit ' .. vim.uri_to_fname(result))
              end, bufnr)
            end, '[C]langd Switch [H]eader/Source')
          end

          -- Highlight the symbol under the cursor while it is held.
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local hl = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = hl,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = hl,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints (<leader>th) when the server supports them.
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
