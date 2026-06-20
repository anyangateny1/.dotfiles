-- ═══════════════════════════════════════════════════════════════════════════
--  Formatting — conform.nvim
-- ═══════════════════════════════════════════════════════════════════════════
--
--  Adding a formatter
--    1. Add the Mason package name to ensure_installed in lsp.lua.
--    2. Add  filetype = { 'tool-name' }  to formatters_by_ft below.
--    3. If the tool needs custom flags or a run condition, add a block in
--       formatters {} at the bottom of this file.
--
--  Keymaps
--    <leader>f   format buffer / selection
--    <leader>cf  :ConformInfo — show active formatters for the current buffer
--
--  Notes
--    • Format on save is always on.
--    • lsp_format = 'never' — LSPs never format; conform owns all formatting.
--    • clang-format only runs when a .clang-format file is found upward from
--      the buffer; both format-on-save and the manual keymap are guarded.
--
-- ═══════════════════════════════════════════════════════════════════════════

-- Helper used by the C/C++ formatter and format_on_save guard.
local function find_clang_style(path)
  return vim.fs.find({ '.clang-format', '_clang-format', 'clang-format.yaml' }, {
    path = path,
    upward = true,
  })[1]
end

local function has_clang_style(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  return find_clang_style(filename) ~= nil
end

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },

  keys = {
    {
      '<leader>f',
      function()
        local ft = vim.bo.filetype
        if (ft == 'c' or ft == 'cpp') and not has_clang_style(0) then
          vim.notify('clang-format: no .clang-format file found — skipping', vim.log.levels.WARN)
          return
        end
        require('conform').format { async = true, lsp_format = 'never' }
      end,
      mode = { 'n', 'v' },
      desc = '[F]ormat buffer',
    },
    {
      '<leader>cf',
      '<cmd>ConformInfo<cr>',
      desc = '[C]onform In[f]o',
    },
  },

  opts = {
    notify_on_error = false,

    -- Skip format-on-save for C/C++ when there is no style file.
    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      if (ft == 'c' or ft == 'cpp') and not has_clang_style(bufnr) then
        return nil
      end
      return { timeout_ms = 500, lsp_format = 'never' }
    end,

    -- ── Formatters by filetype ─────────────────────────────────────────────
    -- One language per line; add a comment if the choice isn't obvious.
    -- Multiple tools run left-to-right (e.g. imports first, then format).
    formatters_by_ft = {
      -- Lua
      lua = { 'stylua' },

      -- C / C++  (only runs when a .clang-format file exists — see condition below)
      c = { 'clang-format' },
      cpp = { 'clang-format' },

      python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },

      go = { 'gofumpt', 'goimports' },

      -- Web — JS/TS  (prettier only; ESLint fixes come from the ESLint LSP via code-action)
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },

      -- Web — styles & markup
      css = { 'prettier' },
      scss = { 'prettier' },
      less = { 'prettier' },
      html = { 'prettier' },

      -- Data / config
      json = { 'prettier' },
      jsonc = { 'prettier' },
      yaml = { 'prettier' },

      -- Prose
      markdown = { 'prettier' },
    },

    -- ── Per-formatter overrides ────────────────────────────────────────────
    formatters = {
      -- clang-format: only run when a style file exists, and use that file's directory as cwd.
      ['clang-format'] = {
        condition = function(_, ctx)
          return find_clang_style(ctx.filename) ~= nil
        end,
        cwd = function(_, ctx)
          local style_file = find_clang_style(ctx.filename)
          return style_file and vim.fs.dirname(style_file) or nil
        end,
        prepend_args = { '-style=file' },
      },

      -- ruff: enforce the same line length across all three sub-formatters.
      ruff_format = { prepend_args = { '--config', 'line-length=100' } },
      ruff_fix = { prepend_args = { '--config', 'line-length=100' } },
      ruff_organize_imports = { prepend_args = { '--config', 'line-length=100' } },
    },
  },
}
