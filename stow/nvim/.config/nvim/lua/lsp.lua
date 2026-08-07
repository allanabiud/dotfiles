local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_blink, blink = pcall(require, "blink.cmp")
if ok_blink then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

-- Apply completion capabilities to every server (mason auto-enables these)
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- ===== per-language LSP configuration =====

-- lua_ls: teach it about the Neovim runtime so vim.* completes & doesn't false-error
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath("config") .. "/lua",
        },
      },
      telemetry = { enable = false },
    },
  },
})

-- pyright: pyright's default type checking is "off"; enable basic level
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
      },
    },
  },
})

-- yamlls: GitHub Actions schema (defaults already cover completion/validation)
vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*.{yml,yaml}",
      },
    },
  },
})

-- texlab: only override chktex-on-save (build defaults are already latexmk)
vim.lsp.config("texlab", {
  settings = {
    texlab = {
      chktex = {
        onOpenAndSave = true,
      },
    },
  },
})

-- Enable LSPs Manually (Not managed by mason)
-- Dart LSP
vim.lsp.enable("dartls")
-- GDScript LSP
vim.lsp.enable("gdscript")
-- GDShader LSP
vim.lsp.enable("gdshader_lsp")

-- Keymaps
local keymap = vim.keymap
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    opts.desc = "Code actions"
    keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

    opts.desc = "Rename symbol"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    opts.desc = "Previous diagnostic"
    keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)

    opts.desc = "Next diagnostic"
    keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)

    opts.desc = "Hover documentation"
    keymap.set("n", "K", vim.lsp.buf.hover, opts)

    opts.desc = "Restart LSP"
    keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
  end,
})

-- Diagnostic Symbols
local severity = vim.diagnostic.severity

vim.diagnostic.config({
  signs = {
    text = {
      [severity.ERROR] = " ",
      [severity.WARN] = " ",
      [severity.INFO] = " ",
      [severity.HINT] = "󰠠 ",
    },
  },
})
