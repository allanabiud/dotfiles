return {
  -- VSCode
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    config = function()
      -- Lua:
      -- For dark theme (neovim's default)
      vim.o.background = "dark"
      -- For light theme
      -- vim.o.background = "light"

      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        -- Alternatively set style in setup
        -- style = 'light'

        -- Enable transparent background
        transparent = true,

        -- Enable italic comment
        italic_comments = true,

        -- Underline `@markup.link.*` variants
        underline_links = true,

        -- Disable nvim-tree background color
        disable_nvimtree_bg = true,

        -- Override colors (see ./lua/vscode/colors.lua)
        color_overrides = {
          vscLineNumber = "#FFFFFF",
        },

        -- Override highlight groups (see ./lua/vscode/theme.lua)
        group_overrides = {
          -- this supports the same val table as vim.api.nvim_set_hl
          -- use colors from this colorscheme by requiring vscode.colors!
          Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        },
      })
      -- require('vscode').load()

      -- load the theme without affecting devicon colors.
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- Tokyo Night
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1000,
  --   config = function()
  --     require("tokyonight").setup({
  --       transparent = true,
  --       styles = {
  --         sidebars = "transparent",
  --         floats = "transparent",
  --       },
  --     })
  --
  --     vim.cmd("colorscheme tokyonight")
  --   end,
  -- },

  -- One Dark
  -- {
  --   "navarasu/onedark.nvim",
  --   lazy = false,
  --   config = function()
  --     -- Lua
  --     require("onedark").setup({
  --       -- Main options --
  --       style = "darker", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
  --       transparent = false, -- Show/hide background
  --       term_colors = true, -- Change terminal color as per the selected theme style
  --       ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
  --       cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
  --
  --       -- toggle theme style ---
  --       toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it   to a string, for example "<leader>ts"
  --       toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle between
  --
  --       -- Change code style ---
  --       -- Options are italic, bold, underline, none
  --       -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
  --       code_style = {
  --         comments = "italic",
  --         keywords = "none",
  --         functions = "none",
  --         strings = "none",
  --         variables = "none",
  --       },
  --
  --       -- Lualine options --
  --       lualine = {
  --         transparent = false, -- lualine center bar transparency
  --       },
  --
  --       -- Custom Highlights --
  --       colors = {}, -- Override default colors
  --       highlights = {}, -- Override highlight groups
  --
  --       -- Plugins Config --
  --       diagnostics = {
  --         darker = true, -- darker colors for diagnostic
  --         undercurl = true, -- use undercurl instead of underline for diagnostics
  --         background = true, -- use background color for virtual text
  --       },
  --     })
  --     require("onedark").load()
  --   end,
  -- },
}
