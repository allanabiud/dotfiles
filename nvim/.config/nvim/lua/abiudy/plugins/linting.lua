return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      sh = { "shellcheck" },
      python = { "mypy", "ruff" },
      html = { "htmlhint" },
      htmldjango = { "htmlhint", "djlint" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
    }

    -- configure linters
    -- htmlhint
    lint.linters.htmlhint.args = {
      "--config",
      vim.json.encode({
        ["spec-char-escape"] = false,
      }),
    }
    -- mypy
    lint.linters.mypy.args = {
      "--config",
      ["ignore_missing_imports"] = true,
    }
    lint.linters.eslint_d = {
      cmd = "eslint_d",
      args = { "--stdin", "--stdin-filename", vim.fn.expand("%:p"), "--format", "compact" },
      stdin = true,
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(
        [[(%d+):(%d+) [%w/]+ (.+)]],
        { "line", "col", "message" },
        nil,
        { source = "eslint_d" }
      ),
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
