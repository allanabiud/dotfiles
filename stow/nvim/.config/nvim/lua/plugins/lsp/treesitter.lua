return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = {
        "lua",
        "markdown",
        "html",
        "htmldjango",
        "css",
        "bash",
        "javascript",
        "hyprlang",
        "c_sharp",
        "gdscript",
        "godot_resource",
        "gdshader",
      },
      auto_install = true,
      highlight = {
        enable = true,
        -- disable = { "html" },
        -- additional_vim_regex_highlighting = false,
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
