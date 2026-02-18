-- nvim-surround - Add/change/delete surrounding delimiter pairs with ease
-- Examples: cs"' (change surrounding " to '), ds" (delete surrounding "), ys2w" (surround 2 words with ")
return {
  "kylechui/nvim-surround",
  version = "*", -- Use for stability; omit to use `main` branch for the latest features
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Configuration here, or leave empty to use defaults
      keymaps = {
        insert = "<C-g>s",
        insert_line = "<C-g>S",
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yS",
        normal_cur_line = "ySS",
        visual = "S",
        visual_line = "gS",
        delete = "ds",
        change = "cs",
        change_line = "cS",
      },
      surrounds = {
        -- Custom surround pairs can be added here
        -- Example: ["*"] = { add = { "*", "*" }, find = "%*.--%*", delete = "^(.)().-(.)()$" },
      },
      aliases = {
        ["a"] = ">", -- Single character aliases apply everywhere
        ["b"] = ")",
        ["B"] = "}",
        ["r"] = "]",
        ["q"] = { '"', "'", "`" }, -- Quote family
      },
      highlight = {
        duration = 200, -- Duration of highlight in milliseconds
      },
      move_cursor = "begin", -- "begin" | "end" | false
      indent_lines = function(start, stop)
        -- Only indent the line if a newline is inserted
        local b = vim.fn.getline(start)
        local a = vim.fn.getline(stop)
        return a:match("^%s*$") and b:match("^%s*$")
      end,
    })
  end
} 