return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        local base16 = require("base16-colorscheme").colors
        if not base16 then return end
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = base16.base08 })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = base16.base0A })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = base16.base0D })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = base16.base09 })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = base16.base0B })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = base16.base0E })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = base16.base0C })
      end)

      require("ibl").setup({
        indent = {
          -- char = "┊",
          char = "│",
          -- highlight = highlight,
        },
        scope = {
          enabled = true,
          char = "│",
          show_start = true,
          show_end = false,
          highlight = highlight,
        },
      })
    end,
  },
}
