return {
  "python-lsp/python-lsp-ruff",
  dependencies = {
    "python-lsp/python-lsp-black",
    "chantera/python-lsp-isort",
  },

  config = function()
    local lspconfig = require("lspconfig")

    lspconfig.pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = { "W391" },
              maxLineLength = 150,
            },
            ruff = {
              enabled = true, -- Enable Ruff
              lineLength = 88, -- Optionally set line length (default is 88)
            },
            black = {
              enabled = true,
              line_length = 88, -- Set the line length for Black (default is 88)
            },
            isort = {
              enabled = true,
            },
          },
        },
      },
    })
  end,
}
