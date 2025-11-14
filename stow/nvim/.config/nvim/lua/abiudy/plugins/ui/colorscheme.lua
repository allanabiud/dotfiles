return {
  -- {
  --   "olimorris/onedarkpro.nvim",
  --   event = "VimEnter",
  --   priority = 1000, -- Ensure it loads first
  --   config = function()
  --     require("onedarkpro").setup({
  --       colors = {
  --         dark = { bg = "#050505" },
  --       },
  --       options = {
  --         transparency = false,
  --       },
  --       highlights = {
  --         Comment = { italic = true, fg = "#a3a6ad" },
  --         Directory = { bold = true },
  --         ErrorMsg = { italic = true, bold = true },
  --       },
  --     })
  --     vim.cmd("colorscheme onedark_dark")
  --   end,
  -- },
  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   config = function()
  --     vim.o.background = "dark"
  --
  --     local c = require("vscode.colors").get_colors()
  --     require("vscode").setup({
  --       transparent = false,
  --       italic_comments = true,
  --       underline_links = true,
  --       disable_nvimtree_bg = true,
  --       -- Override colors (see ./lua/vscode/colors.lua)
  --       color_overrides = {
  --         vscLineNumber = "#FFFFFF",
  --         vscBack = "#050505",
  --         vscPopupBack = "#050505",
  --       },
  --       -- Override highlight groups (see ./lua/vscode/theme.lua)
  --       group_overrides = {
  --         -- this supports the same val table as vim.api.nvim_set_hl
  --         -- use colors from this colorscheme by requiring vscode.colors!
  --         Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
  --       },
  --     })
  --     -- require('vscode').load()
  --
  --     -- load the theme without affecting devicon colors.
  --     vim.cmd.colorscheme("vscode")
  --   end,
  -- },
  -- {
  --   "rebelot/kanagawa.nvim",
  --   config = function()
  --     require("kanagawa").setup({})
  --     vim.cmd("colorscheme kanagawa-dragon")
  --   end,
  -- },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        on_colors = function(colors)
          local dark = "#050505"
          local tinted_blue = "#162238"

          -- Core backgrounds
          colors.bg = dark
          colors.bg_dark = dark
          colors.bg_dark1 = dark
          colors.bg_sidebar = dark
          colors.bg_float = dark
          colors.bg_statusline = dark
          colors.bg_popup = dark
          colors.bg_highlight = tinted_blue
        end,
        on_highlights = function(hl, colors)
          -- Remove background highlight for references
          hl.MiniCursorword = { underline = true, bg = "NONE" }
          hl.MiniCursorwordCurrent = { underline = true, bg = "NONE" }
        end,
      })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
}
