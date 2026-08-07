return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    vim.filetype.add({
      pattern = { [".*/hypr/.*%.conf"] = "hyprlang" },
    })
    require("nvim-treesitter").install({
      "lua",
      "bash",
      "markdown",
      "markdown_inline",
      "python",
      "javascript",
      "typescript",
      "html",
      "htmldjango",
      "css",
      "regex",
      "vimdoc",
      "vim",
      "dart",
      "gdscript",
      "gdshader",
      "toml",
      "yaml",
      "json",
      "hyprlang",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local buf, ft = args.buf, vim.bo[args.buf].filetype
        if vim.bo[buf].buftype ~= "" then
          return
        end

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang or not vim.treesitter.language.add(lang) then
          return
        end

        vim.treesitter.start(buf, lang)

        if ft == "javascriptreact" or ft == "typescriptreact" then
          vim.opt_local.foldmethod = "indent"
        else
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end

        if not vim.tbl_contains({ "python", "html", "htmldjango", "yaml", "markdown" }, ft) then
          vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end
      end,
    })

    require("nvim-ts-autotag").setup()
  end,
}
