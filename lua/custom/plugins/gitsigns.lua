-- lua/custom/plugins/gitsigns.lua
return {
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  },
  config = function(_, opts)
    require('gitsigns').setup(opts)

    local gs = package.loaded.gitsigns

    -- Navigation between hunks
    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return '<Ignore>'
    end, { expr = true, desc = 'Next Git Hunk' })

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then
        return '[c'
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return '<Ignore>'
    end, { expr = true, desc = 'Previous Git Hunk' })

    -- Hunk actions
    vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage Hunk' })
    vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset Hunk' })
    vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage Buffer' })
    vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo Stage Hunk' })
    vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset Buffer' })
    vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview Hunk' })
    vim.keymap.set('n', '<leader>hb', gs.blame_line, { desc = 'Blame Line' })
  end,
}
