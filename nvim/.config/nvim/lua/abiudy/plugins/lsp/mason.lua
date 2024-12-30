return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
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

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
        "html",
        "cssls",
        "pyright",
        "marksman",
        "bashls",
        "emmet_language_server",
        "ts_ls",
        "gopls",
      },
      -- automatic installation of servers
      automatic_installation = true, -- not the same as ensure_installed
    })

    -- auto install formatters
    mason_tool_installer.setup({
      ensure_installed = {
        "stylua", -- lua formatter
        "prettier", -- prettier formatter
        "htmlhint", -- html linter
        "djlint", -- htmldjango linter
        "isort", -- python formatter
        "black", -- python formatter
        "mypy", -- python linter
        "ruff", -- python linter and formatter
        "shfmt", -- shell formatter
        "shellcheck", -- shell linter
        { "eslint_d", version = "13.1.2" }, -- javascript linter
      },
    })
  end,
}
