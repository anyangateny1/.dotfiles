-- Debug Adapter Protocol (DAP). Project-specific configs live in .vscode/launch.json.
-- See ~/.config/nvim/docs/debugging.md and launch.json.example.

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

    local function pick_executable()
      local uv = vim.uv or vim.loop
      local cwd = vim.fn.getcwd()
      local build_dir = vim.fs.joinpath(cwd, 'build')
      local candidates = {}

      if uv.fs_stat(build_dir) then
        candidates = vim.fs.find(function(name, path)
          if name:match '%.so$' or name:match '%.a$' or name:match '%.o$' then
            return false
          end

          local full_path = vim.fs.joinpath(path, name)
          return vim.fn.executable(full_path) == 1
        end, {
          path = build_dir,
          limit = 20,
          type = 'file',
        })
      end

      local default = candidates[1] or build_dir .. '/'
      return vim.fn.input('Path to executable: ', default, 'file')
    end

    local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'
    require('dap-python').setup(mason_packages .. '/debugpy/venv/bin/python')

    require('nvim-dap-virtual-text').setup {
      commented = true,
    }

    dap.configurations.cpp = {
      {
        name = 'Launch executable',
        type = 'codelldb',
        request = 'launch',
        program = pick_executable,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = function()
          local args = vim.fn.input 'Arguments: '
          return vim.split(args, ' ', { trimempty = true })
        end,
      },
      {
        name = 'Attach to process',
        type = 'codelldb',
        request = 'attach',
        pid = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
      },
    }
    dap.configurations.c = dap.configurations.cpp

    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = 'python', -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = 'launch',
        name = 'Launch file',

        program = '${file}', -- This configuration will launch the current file if used.
        pythonPath = function()
          local cwd = vim.fn.getcwd()
          if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
            return cwd .. '/venv/bin/python'
          elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
            return cwd .. '/.venv/bin/python'
          else
            return '/usr/bin/python'
          end
        end,
      },
    }

    require('dap.ext.vscode').load_launchjs(nil, { codelldb = { 'c', 'cpp' } })

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
