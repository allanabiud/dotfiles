return {
  "tweekmonster/django-plus.vim",
  event = "VeryLazy",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  ft = { "python", "django", "htmldjango" },
  config = function()
    local lspconfig = require("lspconfig")

    -- 1. Enhanced Filetype Detection
    vim.g.django_filetypes = 1
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
      pattern = {
        "*/templates/*.html",
        "*/templates/*/*.html",
        "*/templates/*/*/*.html",
      },
      callback = function()
        vim.bo.filetype = "htmldjango"
      end,
    })

    -- 2. Extended Keymappings
    local opts = { noremap = true, silent = true }
    -- Your existing mappings
    vim.keymap.set("n", "<leader>dv", ":DjangoViewToggle<CR>", opts)
    vim.keymap.set("n", "<leader>dm", ":DjangoModelToggle<CR>", opts)
    vim.keymap.set("n", "<leader>dt", ":DjangoURLToggle<CR>", opts)

    -- Additional useful mappings
    vim.keymap.set("n", "<leader>df", ":DjangoFormToggle<CR>", opts) -- Toggle between form/model
    vim.keymap.set("n", "<leader>da", ":DjangoAdminToggle<CR>", opts) -- Toggle between model/admin
    vim.keymap.set("n", "<leader>ds", ":DjangoTestToggle<CR>", opts) -- Toggle between code/tests

    -- Template tag snippets with better positioning
    vim.keymap.set("i", "{%", "{%  %}<Left><Left><Left>", opts)
    vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", opts)
    -- Additional useful template snippets
    vim.keymap.set("i", "{#", "{#  #}<Left><Left><Left>", opts)
    vim.keymap.set("i", "-%}", "{%-  -%}<Left><Left><Left><Left>", opts)

    -- Quick block snippets
    vim.keymap.set(
      "i",
      "block%",
      "{% block  %}{% endblock %}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>",
      opts
    )
    vim.keymap.set(
      "i",
      "for%",
      "{% for  in %}{% endfor %}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>",
      opts
    )
    vim.keymap.set(
      "i",
      "if%",
      "{% if  %}{% endif %}<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>",
      opts
    )

    -- 3. Enhanced Syntax Configuration
    vim.g.django_highlight_builtins = 1
    vim.g.django_highlight_common_tags = 1
    vim.g.django_highlight_errors = 1
    vim.g.python_highlight_all = 1

    -- 4. Improved Project Settings
    local function find_django_root()
      -- Try to find manage.py in parent directories
      local current = vim.fn.getcwd()
      while current ~= "/" do
        if vim.fn.filereadable(current .. "/manage.py") == 1 then
          return current
        end
        current = vim.fn.fnamemodify(current, ":h")
      end
      return vim.fn.getcwd()
    end

    vim.g.django_project_root = find_django_root()
    vim.g.django_manage_py_location = vim.g.django_project_root .. "/manage.py"

    -- 5. Enhanced Django Commands
    local function create_django_command(name, args)
      vim.api.nvim_create_user_command("Django" .. name, function(opts)
        local cmd =
          string.format("terminal python %s %s %s", vim.g.django_manage_py_location, args or name:lower(), opts.args)
        vim.cmd(cmd)
      end, { nargs = "*" })
    end

    -- Register common Django commands
    local django_commands = {
      "RunServer",
      "MakeMigrations",
      "Migrate",
      "Shell",
      "DBShell",
      "Test",
      "CheckMigrations",
      "CollectStatic",
      "CreateSuperuser",
    }

    for _, cmd in ipairs(django_commands) do
      create_django_command(cmd)
    end

    -- Custom command for quickly creating new apps
    vim.api.nvim_create_user_command("DjangoCreateApp", function(opts)
      if opts.args == "" then
        print("Please provide an app name")
        return
      end
      vim.cmd(string.format("terminal python %s startapp %s", vim.g.django_manage_py_location, opts.args))
    end, { nargs = 1 })

    -- 6. Enhanced Pyright Configuration
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

    -- 7. File Templates for Django
    vim.api.nvim_create_autocmd("BufNewFile", {
      pattern = "*/models.py",
      callback = function()
        local template = {
          "from django.db import models",
          "",
          "",
          "class MyModel(models.Model):",
          "    # Your model fields here",
          "    created_at = models.DateTimeField(auto_now_add=True)",
          "    updated_at = models.DateTimeField(auto_now=True)",
          "",
          "    class Meta:",
          "        verbose_name = 'My Model'",
          "        verbose_name_plural = 'My Models'",
          "",
          "    def __str__(self):",
          "        return str(self.id)",
          "",
        }
        vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
      end,
    })
  end,
}
