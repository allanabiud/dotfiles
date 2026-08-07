return {
  "williamboman/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- auto-enables any server installed below (vim.lsp.enable)
    mason_lspconfig.setup()

    -- single source of truth for everything mason installs
    mason_tool_installer.setup({
      ensure_installed = {
        -- lsp servers
        "lua-language-server",
        "html-lsp",
        "css-lsp",
        "pyright",
        "marksman",
        "bash-language-server",
        "emmet-language-server",
        "typescript-language-server",
        "taplo",
        "yaml-language-server",
        "texlab",
        -- formatters
        "stylua",
        "prettier",
        "isort",
        "black",
        "shfmt",
        "gdtoolkit",
        -- linters
        "htmlhint",
        "djlint",
        "mypy",
        "ruff",
        "shellcheck",
        "eslint_d",
      },
    })
  end,
}
