return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  }, -- if you use the mini.nvim suite
  config = function()
    require("render-markdown").setup({})
  end,
}
