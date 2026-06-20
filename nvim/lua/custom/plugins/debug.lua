-- ═══════════════════════════════════════════════════════════════════════════
--  Debugging — nvim-dap
-- ═══════════════════════════════════════════════════════════════════════════
--
--  Adapters installed by Mason (mason-nvim-dap auto-configures them):
--    delve    → Go    (nvim-dap-go wraps it)
--    debugpy  → Python (nvim-dap-python wraps it)
--    codelldb → C / C++
--
--  Adding a new adapter
--    1. Add the adapter name to ensure_installed below.
--    2. Mason auto-applies the default config. For custom args, add a handler:
--         handlers = { my_adapter = function() ... end }
--    3. Per-project launch configs live in .vscode/launch.json.
--
--  Python venvs
--    The adapter itself always runs from Mason's debugpy venv (see setup below).
--    For the *debuggee* Python (your project's interpreter), nvim-dap-python
--    resolves it in this order:
--      1. .venv/bin/python  in the workspace root  (auto-detected, no config needed)
--      2. $VIRTUAL_ENV  if you activated the venv before launching nvim
--      3. Falls back to the Mason debugpy python
--    Most projects with a standard .venv/ dir at the root just work.
--    For non-standard layouts, put the path in .vscode/launch.json:
--      "pythonPath": "${workspaceFolder}/my-env/bin/python"
--
-- ═══════════════════════════════════════════════════════════════════════════

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
    'mfussenegger/nvim-dap-python',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI',
    },
    {
      '<leader>dd',
      function()
        require('dap').select_config_to_run()
      end,
      desc = 'Debug: Pick launch config',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { 'delve', 'codelldb', 'debugpy' },
    }

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Per-project configs: .vscode/launch.json (auto-loaded by nvim-dap).
    -- Template: ~/.config/nvim/launch.json.example

    -- Inline variable values while stepping through code.
    require('nvim-dap-virtual-text').setup {
      commented = true, -- show virtual text as a comment
    }

    -- Point the adapter at Mason's debugpy venv, not the system python3.
    local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'
    require('dap-python').setup(mason_packages .. '/debugpy/venv/bin/python')

    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
