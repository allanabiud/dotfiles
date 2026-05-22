return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = {
        "lua",
        "markdown",
        "markdown_inline",
        "bash",
        "python",
        "javascript",
        "typescript",
        "html",
        "css",
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = false },
      autotag = { enable = true },
    })
    -- Hyprlang Auto-Detection
    vim.filetype.add({
      pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
    })

    vim.treesitter.language.register("html", "ejs")
    vim.treesitter.language.register("javascript", "ejs")
  end,
}
