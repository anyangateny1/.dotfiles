-- Work-machine extras (work_vim branch only).
-- home-pc does not include this file; work_vim rebases on home-pc + this overlay.

return {
  {
    'nvim-telescope/telescope.nvim',
    opts = function(_, opts)
      opts.defaults = vim.tbl_deep_extend('force', opts.defaults or {}, {
        file_ignore_patterns = {
          'node_modules',
          'subprojects',
          'build/_deps',
          'external',
        },
      })
    end,
  },
}
