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
        csharp = { "csharpier" },
        gdscript = { "gdformat" },
        json = { "prettier" },
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
        gdformat = {
          command = "gdformat",
          args = { "-" },
          stdin = true,
        },
      },
    })
  end,
}
