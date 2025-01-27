return {
  "cachebag/nvim-tcss",
  config = function()
    require("tcss").setup({
      -- Enable syntax highlighting (default: true)
      enable = true,

      -- Custom color overrides
      colors = {
        -- Add custom highlighting rules here
      },
    })
  end,
}
