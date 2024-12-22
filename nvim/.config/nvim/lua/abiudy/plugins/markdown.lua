return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("render-markdown").setup({})
  end,
}
