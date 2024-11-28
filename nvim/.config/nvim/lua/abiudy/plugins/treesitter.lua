return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "lua", "markdown", "html", "htmldjango", "css", "bash", "javascript" },
      auto_install = true,
      highlight = {
        enable = true,
        -- disable = { "html" },
        -- additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      autotag = { enable = true },
    })
  end,
}
