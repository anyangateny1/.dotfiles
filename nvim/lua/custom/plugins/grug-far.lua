return {
  'MagicDuck/grug-far.nvim',
  cmd = 'GrugFar',
  keys = {
    {
      '<leader>sR',
      function()
        require('grug-far').open { prefills = { search = vim.fn.expand '<cword>' } }
      end,
      desc = '[S]earch and [R]eplace (project-wide)',
    },
    {
      '<leader>sR',
      function()
        require('grug-far').with_visual_selection()
      end,
      mode = 'v',
      desc = '[S]earch and [R]eplace selection',
    },
  },
  opts = {
    headerMaxWidth = 80,
  },
}
