return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  opts = {
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },
    spec = {
      -- Basic navigation and editing
      { "<Esc>", desc = "Clear search highlights" },
      { "<C-s>", desc = "Save all buffers" },
      { "<C-d>", desc = "Scroll down (centered)" },
      { "<C-u>", desc = "Scroll up (centered)" },
      { "<C-h>", desc = "Move to left window" },
      { "<C-j>", desc = "Move to lower window" },
      { "<C-k>", desc = "Move to upper window" },
      { "<C-l>", desc = "Move to right window" },
      
      -- Terminal mode
      { "<Esc><Esc>", desc = "Exit terminal mode", mode = "t" },
      
      -- Leader key groups
      { "<leader>c", group = "[C]ode" },
      { "<leader>ca", desc = "Code [A]ctions" },
      { "<leader>ch", desc = "Go to [H]eader declaration" },
      { "<leader>ct", desc = "Go to [T]ype definition" },
      { "<leader>cI", desc = "Show [I]nclude hierarchy" },
      { "<leader>cf", desc = "[C]onform [F]ormat - Debug formatter" },
      
      { "<leader>d", group = "[D]ocument" },
      { "<leader>ds", desc = "[D]ocument [S]ymbols" },
      { "<leader>D", desc = "Type [D]efinition" },
      
      { "<leader>f", desc = "[F]ormat buffer" },
      
      { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      
      { "<leader>q", desc = "Open diagnostic quickfix list" },
      
      { "<leader>r", group = "[R]ename" },
      { "<leader>rn", desc = "[R]e[n]ame symbol" },
      
      { "<leader>s", group = "[S]earch" },
      { "<leader>sh", desc = "[S]earch [H]elp" },
      { "<leader>sk", desc = "[S]earch [K]eymaps" },
      { "<leader>sf", desc = "[S]earch [F]iles" },
      { "<leader>ss", desc = "[S]earch [S]elect Telescope" },
      { "<leader>sw", desc = "[S]earch current [W]ord" },
      { "<leader>sg", desc = "[S]earch by [G]rep" },
      { "<leader>sd", desc = "[S]earch [D]iagnostics" },
      { "<leader>sr", desc = "[S]earch [R]esume" },
      { "<leader>s.", desc = "[S]earch Recent Files" },
      { "<leader>s/", desc = "[S]earch in Open Files" },
      { "<leader>sn", desc = "[S]earch [N]eovim files" },
      
      { "<leader>t", group = "[T]oggle" },
      { "<leader>th", desc = "[T]oggle Inlay [H]ints" },
      
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>ws", desc = "[W]orkspace [S]ymbols" },
      
      { "<leader>/", desc = "Fuzzily search in current buffer" },
      { "<leader><leader>", desc = "Find existing buffers" },
      
      -- LSP navigation (using defaults from Neovim 0.11.3)
      { "g", group = "[G]oto" },
      { "gd", desc = "[G]oto [D]efinition" },
      { "gr", desc = "[G]oto [R]eferences" },
      { "gI", desc = "[G]oto [I]mplementation" },
      { "gD", desc = "[G]oto [D]eclaration" },
      
      -- Hover documentation
      { "K", desc = "Hover Documentation" },
      
      -- Completion mappings (insert mode)
      { "<C-n>", desc = "Next completion item", mode = "i" },
      { "<C-p>", desc = "Previous completion item", mode = "i" },
      { "<C-b>", desc = "Scroll docs up", mode = "i" },
      { "<C-f>", desc = "Scroll docs down", mode = "i" },
      { "<C-y>", desc = "Confirm completion", mode = "i" },
      { "<C-Space>", desc = "Complete", mode = "i" },
      { "<C-l>", desc = "Snippet jump forward", mode = { "i", "s" } },
      { "<C-h>", desc = "Snippet jump backward", mode = { "i", "s" } },
      
      -- Surround plugin mappings
      { "ys", desc = "Surround add" },
      { "yss", desc = "Surround current line" },
      { "yS", desc = "Surround add line" },
      { "ySS", desc = "Surround current line (linewise)" },
      { "S", desc = "Surround add", mode = "v" },
      { "gS", desc = "Surround add line", mode = "v" },
      { "ds", desc = "Surround delete" },
      { "cs", desc = "Surround change" },
      { "cS", desc = "Surround change line" },
      
      -- Neo-tree file explorer
      { "\\", desc = "NeoTree reveal" },
      { "<leader>e", desc = "Toggle NeoTree" },
      { "<leader>ne", desc = "Focus NeoTree" },
      
      -- Trouble diagnostics
      { "<leader>x", group = "Trouble" },
      { "<leader>xx", desc = "Toggle Trouble" },
      { "<leader>xw", desc = "Workspace Diagnostics" },
      { "<leader>xd", desc = "Document Diagnostics" },
      { "<leader>xq", desc = "Quickfix List" },
      { "<leader>xl", desc = "Location List" },
      { "gR", desc = "LSP References (Trouble)" },
      { "[t", desc = "Previous trouble/quickfix item" },
      { "]t", desc = "Next trouble/quickfix item" },
      
      -- Debug Adapter Protocol (DAP)
      { "<F1>", desc = "Debug: Step Into" },
      { "<F2>", desc = "Debug: Step Over" },
      { "<F3>", desc = "Debug: Step Out" },
      { "<F5>", desc = "Debug: Start/Continue" },
      { "<F7>", desc = "Debug: Toggle UI" },
      { "<leader>b", desc = "Debug: Toggle Breakpoint" },
      { "<leader>B", desc = "Debug: Set Breakpoint" },
    },
  },
} 