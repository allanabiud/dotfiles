return {

  -- OneDark Pro
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
    config = function()
      require("onedarkpro").setup({
        highlights = {
          Comment = { italic = true, fg = "#a3a6ad" },
          Directory = { bold = true },
          ErrorMsg = { italic = true, bold = true },
        },
      })
      vim.cmd("colorscheme onedark_dark")
    end,
  },
  -------------------------------------------------------------------------------
  -- VSCode
  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   config = function()
  --     -- Lua:
  --     -- For dark theme (neovim's default)
  --     vim.o.background = "dark"
  --     -- For light theme
  --     -- vim.o.background = "light"
  --
  --     local c = require("vscode.colors").get_colors()
  --     require("vscode").setup({
  --       -- Alternatively set style in setup
  --       -- style = 'light'
  --
  --       -- Enable transparent background
  --       transparent = true,
  --
  --       -- Enable italic comment
  --       italic_comments = true,
  --
  --       -- Underline `@markup.link.*` variants
  --       underline_links = true,
  --
  --       -- Disable nvim-tree background color
  --       disable_nvimtree_bg = true,
  --
  --       -- Override colors (see ./lua/vscode/colors.lua)
  --       color_overrides = {
  --         vscLineNumber = "#FFFFFF",
  --       },
  --
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
  -------------------------------------------------------------------------------
  -- Flexoki
  -- {
  --   "kepano/flexoki-neovim",
  --   lazy = false,
  --   config = function()
  --     require("lazy").setup({
  --       { "kepano/flexoki-neovim", name = "flexoki" },
  --       -- Set colorscheme after options
  --       vim.cmd("colorscheme flexoki-dark"),
  --     })
  --   end,
  -- },
}
