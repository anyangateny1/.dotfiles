return {
  -- Lua development support
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
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Telescope-based LSP lookups (don't conflict with Lspsaga)
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Clangd-specific keymaps
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
              -- Fallback heuristic if clangd is unavailable
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
            map('<leader>cI', function()
              vim.cmd 'Telescope lsp_incoming_calls'
            end, '[C]langd [I]nclude hierarchy')
          end

          -- Document highlights
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, { bufnr = event.buf }) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
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
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Inlay hints toggle
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, { bufnr = event.buf }) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostics
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
        virtual_text = false,
        virtual_lines = true,
      }

      -- Capabilities (shared by all servers)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      --- Detect C++ include paths dynamically for the current system.
      local function get_system_include_paths()
        local paths = {}
        local candidates = {
          '/usr/include',
          '/usr/local/include',
        }
        local gcc_base = '/usr/include/c++'
        local handle = vim.uv.fs_scandir(gcc_base)
        if handle then
          while true do
            local name, type = vim.uv.fs_scandir_next(handle)
            if not name then
              break
            end
            if type == 'directory' then
              table.insert(candidates, gcc_base .. '/' .. name)
              local arch_dir = '/usr/include/' .. (vim.uv.os_uname().machine or 'x86_64') .. '-linux-gnu/c++/' .. name
              if vim.uv.fs_stat(arch_dir) then
                table.insert(candidates, arch_dir)
              end
              local backward = gcc_base .. '/' .. name .. '/backward'
              if vim.uv.fs_stat(backward) then
                table.insert(candidates, backward)
              end
            end
          end
        end
        local machine = (vim.uv.os_uname().machine or 'x86_64') .. '-linux-gnu'
        local arch_include = '/usr/include/' .. machine
        if vim.uv.fs_stat(arch_include) then
          table.insert(candidates, arch_include)
        end
        for _, path in ipairs(candidates) do
          if vim.uv.fs_stat(path) then
            table.insert(paths, '-I' .. path)
          end
        end
        return paths
      end

      local function get_fallback_flags(filetype)
        local flags = get_system_include_paths()
        table.insert(flags, '-D__STDC_CONSTANT_MACROS')
        table.insert(flags, '-D__STDC_FORMAT_MACROS')
        table.insert(flags, '-D__STDC_LIMIT_MACROS')
        if filetype == 'c' then
          table.insert(flags, '-std=gnu11')
        elseif filetype == 'cpp' then
          table.insert(flags, '-std=c++20')
        end
        return flags
      end

      ------------------------------------------------------------------
      -- SERVER TABLE: Add new LSP servers here (one entry = done).
      -- The loop below handles vim.lsp.config(), vim.lsp.enable(),
      -- and adds the server to mason-tool-installer automatically.
      ------------------------------------------------------------------
      local servers = {
        lua_ls = {
          mason = 'lua-language-server',
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_markers = { '.luarc.json', '.luarc.jsonc', '.stylua.toml', 'stylua.toml', '.git' },
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
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
          root_markers = {
            '.clangd',
            '.clang-tidy',
            '.clang-format',
            'compile_commands.json',
            'compile_flags.txt',
            '.git',
          },
          capabilities = {
            textDocument = {
              completion = { editsNearCursor = true },
            },
            offsetEncoding = { 'utf-8', 'utf-16' },
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
            fallbackFlags = get_fallback_flags 'cpp',
          },
        },

        gopls = {},

        -- To add a new server, just add an entry here.
        -- Use `mason = 'pkg-name'` if the Mason name differs from the lspconfig name.
        -- Examples:
        -- pyright = {},
        -- gopls = {},
        -- ts_ls = { mason = 'typescript-language-server' },
      }

      -- Non-LSP tools that Mason should also install
      local extra_tools = { 'stylua', 'clang-format' }

      -- Configure, enable, and collect all servers in one loop
      local ensure_installed = vim.list_extend({}, extra_tools)
      for name, config in pairs(servers) do
        local mason_name = config.mason or name
        config.mason = nil
        config.capabilities = vim.tbl_deep_extend('force', capabilities, config.capabilities or {})
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
        table.insert(ensure_installed, mason_name)
      end

      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }
    end,
  },
}
