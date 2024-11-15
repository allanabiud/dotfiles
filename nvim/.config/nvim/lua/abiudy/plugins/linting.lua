return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      sh = { "shellcheck" },
      python = { "mypy", "ruff" },
      html = { "htmlhint" },
      htmldjango = { "htmlhint" },
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

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
