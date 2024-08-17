return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    config = function()
      -- Lua
      require("onedark").setup({
        -- Main options --
        style = "darker", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
        transparent = false, -- Show/hide background
        term_colors = true, -- Change terminal color as per the selected theme style
        ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
        cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

        -- toggle theme style ---
        toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
        toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle between

        -- Change code style ---
        -- Options are italic, bold, underline, none
        -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
        code_style = {
          comments = "italic",
          keywords = "none",
          functions = "none",
          strings = "none",
          variables = "none",
        },

        -- Lualine options --
        lualine = {
          transparent = false, -- lualine center bar transparency
        },

        -- Custom Highlights --
        colors = {}, -- Override default colors
        highlights = {}, -- Override highlight groups

        -- Plugins Config --
        diagnostics = {
          darker = true, -- darker colors for diagnostic
          undercurl = true, -- use undercurl instead of underline for diagnostics
          background = true, -- use background color for virtual text
        },
      })
      require("onedark").load()
    end,
  },

  -- Github Theme
  -- {
  --   "projekt0n/github-nvim-theme",
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require("github-theme").setup({
  --       -- ...
  --     })
  --
  --     vim.cmd("colorscheme github_dark_high_contrast")
  --   end,
  -- },

  -- Tokyo Night
  -- {
  --   "folke/tokyonight.nvim",
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     -- local bg = "#011628"
  --     -- local bg_dark = "#011423"
  --     -- local bg_highlight = "#143652"
  --     -- local bg_search = "#0A64AC"
  --     -- local bg_visual = "#275378"
  --     -- local fg = "#CBE0F0"
  --     -- local fg_dark = "#B4D0E9"
  --     -- local fg_gutter = "#627E97"
  --     -- local border = "#547998"
  --
  --     require("tokyonight").setup({
  --       style = "night",
  --       -- on_colors = function(colors)
  --       --   colors.bg = bg
  --       --   colors.bg_dark = bg_dark
  --       --   colors.bg_float = bg_dark
  --       --   colors.bg_highlight = bg_highlight
  --       --   colors.bg_popup = bg_dark
  --       --   colors.bg_search = bg_search
  --       --   colors.bg_sidebar = bg_dark
  --       --   colors.bg_statusline = bg_dark
  --       --   colors.bg_visual = bg_visual
  --       --   colors.border = border
  --       --   colors.fg = fg
  --       --   colors.fg_dark = fg_dark
  --       --   colors.fg_float = fg
  --       --   colors.fg_gutter = fg_gutter
  --       --   colors.fg_sidebar = fg_dark
  --       -- end,
  --     })
  --     -- load the colorscheme here
  --     vim.cmd([[colorscheme tokyonight]])
  --   end,
  -- },
}
