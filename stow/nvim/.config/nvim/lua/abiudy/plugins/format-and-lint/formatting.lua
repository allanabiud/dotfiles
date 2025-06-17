return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        html = { "prettier" },
        htmldjango = { "djlint" },
        css = { "prettier" },
        javascript = { "prettier" },
        markdown = { "prettier" },
        bash = { "shfmt" },
        python = { "isort", "black" },
        go = { "gofmt" },
        ejs = { "prettier_ejs" },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 5000,
      },
      formatters = {
        djlint = {
          prepend_args = { "--indent", "2" },
        },
        prettier_ejs = {
          command = "prettier",
          args = {
            "--plugin",
            "prettier-plugin-ejs",
            "--stdin-filepath",
            "$FILENAME",
          },
          stdin = true,
          require_cwd = true, -- ensures it's only used when Prettier is installed in the project
        },
      },
    })
  end,
}
