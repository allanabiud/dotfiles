return {
  "tweekmonster/django-plus.vim",
  event = { "BufRead", "BufNewFile" },
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  ft = { "python", "django", "htmldjango" },
  config = function()
    local lspconfig = require("lspconfig")
    -- 1. Filetype Detection
    vim.g.django_filetypes = 1 -- Enable automatic filetype detection

    -- 2. Custom Keymappings for Django development
    local opts = { noremap = true, silent = true }

    -- Navigate between Django files
    vim.keymap.set("n", "<leader>dv", ":DjangoViewToggle<CR>", opts) -- Toggle between view and template
    vim.keymap.set("n", "<leader>dm", ":DjangoModelToggle<CR>", opts) -- Toggle between model and admin
    vim.keymap.set("n", "<leader>dt", ":DjangoURLToggle<CR>", opts) -- Toggle between view and URL

    -- Django template tag snippets
    vim.keymap.set("i", "{%", "{%  %}<Left><Left><Left>", opts)
    vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)

    -- 3. Syntax Highlighting Configuration
    vim.g.django_highlight_builtins = 1 -- Highlight Django builtins
    vim.g.django_highlight_common_tags = 1 -- Highlight common template tags
    vim.g.django_highlight_errors = 1 -- Highlight template errors

    -- 4. Project-specific settings
    -- Auto-detect Django project root
    vim.g.django_project_root = vim.fn.getcwd()
    vim.g.django_manage_py_location = vim.fn.getcwd() .. "/manage.py"

    -- 5. Additional Django utilities
    -- Create commands for common Django operations
    vim.api.nvim_create_user_command("DjangoRunServer", function()
      vim.cmd("terminal python manage.py runserver")
    end, {})

    vim.api.nvim_create_user_command("DjangoMakeMigrations", function()
      vim.cmd("terminal python manage.py makemigrations")
    end, {})

    vim.api.nvim_create_user_command("DjangoMigrate", function()
      vim.cmd("terminal python manage.py migrate")
    end, {})
    -- pyright
    lspconfig.pyright.setup({
      handlers = {
        ["textDocument/publishDiagnostics"] = function() end,
      },
      on_attach = function(client, _)
        client.server_capabilities.codeActionProvider = false
      end,
      settings = {
        pyright = {
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            autoSearchPaths = true,
            typeCheckingMode = "basic",
            useLibraryCodeForTypes = true,
            extraPaths = {
              vim.fn.getcwd(), -- Add current directory to Python path
            },
          },
          venvPath = vim.fn.getcwd() .. "/venv",
          venv = "venv",
        },
      },
    })
  end,
}
