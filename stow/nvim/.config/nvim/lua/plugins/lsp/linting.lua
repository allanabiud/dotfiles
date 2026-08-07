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
      gdscript = { "gdlint" },
    }

    -- htmlhint
    lint.linters.htmlhint.args = {
      "--config",
      vim.json.encode({
        ["spec-char-escape"] = false,
      }),
    }

    -- mypy
    lint.linters.mypy.args = {
      "--ignore-missing-imports",
    }
    -- eslint_d
    lint.linters.eslint_d = {
      cmd = "eslint_d",
      args = {
        "--stdin",
        "--stdin-filename",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
        "--format",
        "compact",
      },
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
    -- gdlint
    lint.linters.gdlint = {
      cmd = "gdlint",
      stdin = false,
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

    -- Debounce so slow linters don't fire on every keystroke
    local function debounce(ms, fn)
      local timer
      return function(...)
        local args = { ... }
        if timer then
          timer:stop()
        end
        timer = vim.uv.new_timer()
        timer:start(ms, 0, vim.schedule_wrap(function()
          fn(unpack(args))
        end))
      end
    end

    local function lint_buf(bufnr, linters)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      vim.api.nvim_buf_call(bufnr, function()
        lint.try_lint(linters)
      end)
    end

    -- mypy is slow; run it only on save
    local function fast_linters(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      local all = lint.linters_by_ft[vim.bo[bufnr].filetype] or {}
      local linters = vim.tbl_filter(function(l)
        return l ~= "mypy"
      end, all)
      lint_buf(bufnr, linters)
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd("BufWritePost", {
      group = lint_augroup,
      callback = function(args)
        debounce(200, lint_buf)(args.buf, nil)
      end,
    })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = lint_augroup,
      callback = function(args)
        debounce(300, fast_linters)(args.buf)
      end,
    })
  end,
}
