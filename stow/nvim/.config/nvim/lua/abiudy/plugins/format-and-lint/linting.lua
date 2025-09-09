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
      ejs = { "ejslint" },
      gdscript = { "gdlint" },
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
    -- eslint_d
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
    -- ejslint
    lint.linters.ejslint = {
      cmd = "ejslint",
      stdin = false,
      args = { "$FILENAME" },
      stream = "stderr",
      ignore_exitcode = true,
      parser = require("lint.parser").from_errorformat("%f:%l\n  %m", {
        source = "ejslint",
        severity = vim.diagnostic.severity.ERROR,
      }),
    }

    lint.linters.gdlint = {
      cmd = "gdlint",
      stdin = false,
      args = { "$FILENAME" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = require("lint.parser").from_pattern(
        [[^([^:]+):(%d+): (%w+): (.+)$]],
        { "file", "line", "severity", "message" },
        nil,
        {
          source = "gdlint",
          severity_map = {
            Error = vim.diagnostic.severity.ERROR,
            Warning = vim.diagnostic.severity.WARN,
          },
        }
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
