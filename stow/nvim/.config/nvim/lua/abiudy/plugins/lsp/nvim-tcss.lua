return {
  "cachebag/nvim-tcss",
  config = function()
    require("tcss").setup({
      -- Enable syntax highlighting
      enable = true,
      -- Custom color overrides
      colors = {},
    })
  end,
}
