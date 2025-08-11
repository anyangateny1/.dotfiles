-- Trouble.nvim - A pretty diagnostics, references, telescope results, quickfix and location list
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    position = "bottom", -- position of the list can be: bottom, top, left, right
    height = 10, -- height of the trouble list when position is top or bottom
    width = 50, -- width of the list when position is left or right
    icons = true, -- use devicons for filenames
    mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
    fold_open = "", -- icon used for open folds
    fold_closed = "", -- icon used for closed folds
    group = true, -- group results by file
    padding = true, -- add an extra new line on top of the list
    action_keys = { -- key mappings for actions in the trouble list
      -- map to {} to remove a mapping, for example:
      -- close = {},
      close = "q", -- close the list
      cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
      refresh = "r", -- manually refresh
      jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
      open_split = { "<c-x>" }, -- open buffer in new split
      open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
      open_tab = { "<c-t>" }, -- open buffer in new tab
      jump_close = { "o" }, -- jump to the diagnostic and close the list
      toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
      switch_severity = "s", -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
      toggle_preview = "P", -- toggle auto_preview
      hover = "K", -- opens a small popup with the full multiline message
      preview = "p", -- preview the diagnostic location
      close_folds = { "zM", "zm" }, -- close all folds
      open_folds = { "zR", "zr" }, -- open all folds
      toggle_fold = { "zA", "za" }, -- toggle fold of current file
      previous = "k", -- previous item
      next = "j" -- next item
    },
    indent_lines = true, -- add an indent guide below the fold icons
    auto_open = false, -- automatically open the list when you have diagnostics
    auto_close = false, -- automatically close the list when you have no diagnostics
    auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
    auto_fold = false, -- automatically fold a file trouble list at creation
    auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
    signs = {
      -- icons / text used for a diagnostic
      error = "",
      warning = "",
      hint = "",
      information = "",
      other = ""
    },
    use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
  },
  config = function(_, opts)
    require("trouble").setup(opts)
    
    -- Keymaps for trouble
    vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Toggle Trouble" })
    vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end, { desc = "Workspace Diagnostics" })
    vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end, { desc = "Document Diagnostics" })
    vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = "Quickfix List" })
    vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end, { desc = "Location List" })
    vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end, { desc = "LSP References" })
    
    -- Navigate between trouble items
    vim.keymap.set("n", "[t", function()
      if require("trouble").is_open() then
        require("trouble").previous({skip_groups = true, jump = true})
      else
        local ok, err = pcall(vim.cmd.cprev)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end, { desc = "Previous trouble/quickfix item" })
    
    vim.keymap.set("n", "]t", function()
      if require("trouble").is_open() then
        require("trouble").next({skip_groups = true, jump = true})
      else
        local ok, err = pcall(vim.cmd.cnext)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end, { desc = "Next trouble/quickfix item" })
  end,
} 