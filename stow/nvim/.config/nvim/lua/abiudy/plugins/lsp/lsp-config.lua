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
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap

    -- capabilities for completion
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- UI: diagnostics signs
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Borders on hover
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

    -- Autocmd for keymaps
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- Organize imports for TS
    local function organize_imports()
      local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      }
      vim.lsp.buf.execute_command(params)
    end

    -- gdscript lsp
    vim.lsp.config("gdscript", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Default handler for mason-lspconfig
    mason_lspconfig.setup({
      handlers = {
        -- Default handler
        function(server_name)
          vim.lsp.config(server_name, { capabilities = capabilities })
          vim.lsp.enable(server_name)
        end,

        -- Lua LS
        ["lua_ls"] = function()
          vim.lsp.config("lua_ls", {
            capabilities = capabilities,
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                completion = { callSnippet = "Replace" },
              },
            },
          })
          vim.lsp.enable("lua_ls")
        end,

        -- Pyright
        ["pyright"] = function()
          vim.lsp.config("pyright", {
            capabilities = capabilities,
            handlers = {
              ["textDocument/publishDiagnostics"] = function() end,
            },
            on_init = function(client)
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
              pyright = { disableOrganizeImports = true },
              python = {
                analysis = {
                  autoSearchPaths = true,
                  diagnosticMode = "workspace",
                  typeCheckingMode = "off",
                  useLibraryCodeForTypes = true,
                  extraPaths = {
                    vim.fn.getcwd(),
                    vim.fn.getcwd() .. "/src",
                    vim.fn.getcwd() .. "/apps",
                  },
                  reportGeneralTypeIssues = "none",
                  reportPropertyTypeMismatch = "none",
                  reportMissingImports = true,
                  reportMissingTypeStubs = false,
                },
              },
            },
          })
          vim.lsp.enable("pyright")
        end,

        -- TSServer
        ["tsserver"] = function()
          vim.lsp.config("tsserver", {
            capabilities = capabilities,
            init_options = {
              preferences = { disableSuggestions = true },
            },
            commands = {
              OrganizeImports = {
                organize_imports,
                description = "Organize Imports",
              },
            },
          })
          vim.lsp.enable("tsserver")
        end,

        -- CSS
        ["cssls"] = function()
          vim.lsp.config("cssls", {
            capabilities = capabilities,
            filetypes = { "css", "tcss" },
          })
          vim.lsp.enable("cssls")
        end,

        -- Emmet
        ["emmet_language_server"] = function()
          vim.lsp.config("emmet_language_server", {
            capabilities = capabilities,
            filetypes = { "html", "css", "ejs" },
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
          })
          vim.lsp.enable("emmet_language_server")
        end,
      },
    })
  end,
}
