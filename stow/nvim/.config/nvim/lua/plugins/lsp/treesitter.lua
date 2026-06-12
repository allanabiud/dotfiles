return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  init = function()
    local highlight = function(bufnr, lang)
      if not vim.treesitter.language.add(lang) then
        return vim.notify(
          string.format("Treesitter cannot load parser for language: %s", lang),
          vim.log.levels.INFO,
          { title = "Treesitter" }
        )
      end
      vim.treesitter.start(bufnr)
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ft = vim.bo.filetype
        local bt = vim.bo.buftype
        local buf = args.buf

        if bt ~= "" then
          return
        end

        local ok, treesitter = pcall(require, "nvim-treesitter")
        if not ok then
          return
        end

        -- Treesitter folds
        if ft == "javascriptreact" or ft == "typescriptreact" then
          vim.opt_local.foldmethod = "indent"
        else
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end

        vim.schedule(function()
          if vim.fn.mode() ~= "t" then
            vim.cmd("silent! normal! zx")
          end
        end)

        -- Treesitter indent
        if not vim.tbl_contains({ "python", "html", "yaml", "markdown" }, ft) then
          vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end

        -- Parsers
        if not vim.treesitter.language.get_lang(ft) then
          return
        end

        if vim.tbl_contains(treesitter.get_installed(), ft) then
          highlight(buf, ft)
        elseif vim.tbl_contains(treesitter.get_available(), ft) then
          if vim.fn.executable("tree-sitter") == 1 then
            treesitter.install(ft):await(function()
              highlight(buf, ft)
            end)
          end
        end
      end,
    })
  end,
  opts = {
    install = {
      "lua",
      "bash",
      "markdown",
      "markdown_inline",
      "python",
      "javascript",
      "typescript",
      "html",
      "css",
      "regex",
      "vimdoc",
      "vim",
    },
  },
  config = function(_, opts)
    local treesitter = require("nvim-treesitter")

    -- Hyprlang Auto-Detection
    vim.filetype.add({
      pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
    })

    vim.treesitter.language.register("html", "ejs")
    vim.treesitter.language.register("javascript", "ejs")

    -- Autotag
    require("nvim-ts-autotag").setup()

    -- Check for CLI
    if vim.fn.executable("tree-sitter") ~= 1 then
      vim.api.nvim_echo({
        {
          "tree-sitter CLI not found. Parsers cannot be installed automatically.\n",
          "ErrorMsg",
        },
        {
          "Please install it via your package manager (e.g., brew install tree-sitter or cargo install tree-sitter-cli).",
          "WarningMsg",
        },
      }, true, {})
      return
    end

    -- Use the new setup if it exists, or just install
    if treesitter.setup then
      treesitter.setup(opts)
    end

    treesitter.install(opts.install)
  end,
}
