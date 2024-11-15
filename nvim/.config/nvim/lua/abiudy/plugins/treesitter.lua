return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "lua", "markdown", "html", "css", "bash" },
      auto_install = true,
      highlight = {
        enable = true,
        -- disable = { "html" },
      },
      indent = { enable = true },
      autotag = { enable = true },
    })
  end,
}
