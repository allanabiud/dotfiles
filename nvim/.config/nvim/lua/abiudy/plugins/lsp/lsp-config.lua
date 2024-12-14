return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        -- opts.desc = "Show buffer diagnostics"
        -- keymap.set("n", "<leader>sb", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        -- opts.desc = "Show line diagnostics"
        -- keymap.set("n", "<leader>sl", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    -- border on hover documentation
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = "rounded", -- Options are "none", "single", "double", "rounded", "solid", "shadow"
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
        })
      end,

      --html
      ["html"] = function()
        lspconfig["html"].setup({
          filetypes = { "html", "htmldjango" },
        })
      end,

      -- Lua_ls
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,

      -- Pyright
      ["pyright"] = function()
        lspconfig.pyright.setup({
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
          on_attach = function(client, bufnr)
            client.server_capabilities.codeActionProvider = false

            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
          end,
          on_init = function(client)
            -- Check multiple common virtualenv locations
            local venv_paths = {
              vim.fn.getcwd() .. "/venv/bin/python",
              vim.fn.getcwd() .. "/.venv/bin/python",
              vim.fn.getcwd() .. "/env/bin/python",
            }

            for _, venv in ipairs(venv_paths) do
              if vim.fn.executable(venv) == 1 then
                client.config.settings.python.pythonPath = venv
                client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                break
              end
            end
          end,
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
                extraPaths = {
                  vim.fn.getcwd(), -- Add project root
                  vim.fn.getcwd() .. "/src",
                  vim.fn.getcwd() .. "/apps", -- Common Django apps directory
                },
                -- Django-specific settings
                reportGeneralTypeIssues = "warning",
                reportPropertyTypeMismatch = "warning",
                reportMissingImports = true,
                reportMissingTypeStubs = false,
              },
            },
          },
        })
      end,

      -- Emmet Language Server
      lspconfig["emmet_language_server"].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {
          "html",
          "css",
          "javascript",
          "javascriptreact",
          "typescriptreact",
          "less",
          "sass",
          "scss",
          "pug",
          "eruby",
        },
        -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
        -- **Note:** only the options listed in the table are supported.
        init_options = {
          includeLanguages = {},
          excludeLanguages = {},
          extensionsPath = {},
          preferences = {},
          showAbbreviationSuggestions = true,
          showExpandedAbbreviation = "always",
          showSuggestionsAsSnippets = false,
          syntaxProfiles = {},
          variables = {},
        },
      }),
    })
  end,
}
