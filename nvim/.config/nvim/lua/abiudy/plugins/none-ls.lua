return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "gbprod/none-ls-shellcheck.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.mypy,
        require("none-ls-shellcheck.code_actions"),
        require("none-ls-shellcheck.diagnostics"),
      },
    })

    vim.keymap.set("n", "<leader>fg", vim.lsp.buf.format, { desc = "Format buffer" })
  end,
}
