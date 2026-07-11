return {
  'kkrampis/codex.nvim',
  lazy = true,
  cmd = { 'Codex', 'CodexToggle' },
  keys = {
    {
      '<leader>cc',
      function()
        require('codex').toggle()
      end,
      desc = 'Toggle Codex popup or side-panel',
      mode = { 'n', 't' },
    },
  },
  opts = {
    keymaps = {
      toggle = nil,
      quit = '<C-q>',
    },
    border = 'rounded',
    width = 0.3,
    height = 0.5,
    model = nil,
    autoinstall = true,
    panel = true,
    use_buffer = false,
  },
}
