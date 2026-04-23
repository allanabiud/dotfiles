return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local shortcut_ns = vim.api.nvim_create_namespace("alpha-shortcuts")

    local function footer_text()
      local stamp = os.date(" %a %d %b   %H:%M")
      local ok, lazy = pcall(require, "lazy")
      if not ok then
        return stamp
      end
      local stats = lazy.stats()
      return string.format(" %d/%d plugins  󱐌 %.2fms  •  %s", stats.loaded, stats.count, stats.startuptime, stamp)
    end

    local function recent_files(max_items)
      local lines = {}
      local seen = {}
      for _, path in ipairs(vim.v.oldfiles or {}) do
        if #lines >= max_items then
          break
        end
        if path ~= "" and vim.fn.filereadable(path) == 1 and not seen[path] then
          seen[path] = true
          local short = vim.fn.fnamemodify(path, ":~:.")
          table.insert(lines, string.format("  %d. %s", #lines + 1, short))
        end
      end
      if #lines == 0 then
        return { "  No recent files yet" }
      end
      return lines
    end

    local actions = {
      {
        key = "f",
        label = "Find files",
        run = function()
          require("telescope.builtin").find_files()
        end,
      },
      {
        key = "r",
        label = "Recent files",
        run = function()
          require("telescope.builtin").oldfiles()
        end,
      },
      {
        key = "s",
        label = "Restore session",
        run = function()
          vim.cmd("AutoSession restore")
        end,
      },
      {
        key = "n",
        label = "New file",
        run = function()
          vim.cmd("ene")
        end,
      },
      {
        key = "b",
        label = "Find buffers",
        run = function()
          require("telescope.builtin").buffers()
        end,
      },
      {
        key = "\\",
        label = "Toggle file explorer",
        run = function()
          vim.cmd("Neotree toggle")
        end,
      },
      {
        key = "c",
        label = "Edit Neovim config",
        run = function()
          require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
        end,
      },
      {
        key = "l",
        label = "Lazy plugin manager",
        run = function()
          vim.cmd("Lazy")
        end,
      },
      {
        key = "q",
        label = "Quit Neovim",
        run = function()
          vim.cmd("qa")
        end,
      },
    }

    local function dashboard_columns()
      local left = { "Quick actions", "-------------" }
      for _, action in ipairs(actions) do
        table.insert(left, string.format("[%s] %s", action.key, action.label))
      end

      local right = { "Recent files", "------------" }
      for _, file in ipairs(recent_files(#actions)) do
        local cleaned = (file:gsub("^%s+", ""))
        table.insert(right, cleaned)
      end

      local function pad_right(text, width)
        local text_width = vim.fn.strdisplaywidth(text)
        if text_width >= width then
          return text
        end
        return text .. string.rep(" ", width - text_width)
      end

      local lines = {}
      local left_width = 34
      local count = math.max(#left, #right)
      for i = 1, count do
        local left_line = left[i] or ""
        local right_line = right[i] or ""
        table.insert(lines, "  " .. pad_right(left_line, left_width) .. "  " .. right_line)
      end
      return lines
    end

    local function highlight_shortcuts(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      vim.api.nvim_buf_clear_namespace(bufnr, shortcut_ns, 0, -1)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      for row, line in ipairs(lines) do
        local from, to = line:find("%[[^%]]+%]")
        if from and to then
          vim.api.nvim_buf_add_highlight(bufnr, shortcut_ns, "AlphaShortcut", row - 1, from - 1, to)
        end
      end
    end

    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#dac7ff", bold = true })
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#faf8ff" })
    vim.api.nvim_set_hl(0, "AlphaShortcut", { fg = "#a5ffb9", bold = true })
    vim.api.nvim_set_hl(0, "AlphaRecent", { fg = "#9c98a4" })
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#e0d1ff", italic = true })

    dashboard.section.header.val = {
      "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
      "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
      "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
      "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
      "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
      "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    }
    dashboard.section.header.opts.hl = "AlphaHeader"

    local columns = {
      type = "text",
      val = dashboard_columns(),
      opts = { position = "center", hl = "AlphaButtons" },
    }

    dashboard.section.footer.val = footer_text()
    dashboard.section.footer.opts.hl = "AlphaFooter"

    dashboard.opts.layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      columns,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.opts)

    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        dashboard.section.footer.val = footer_text()
        columns.val = dashboard_columns()
        pcall(vim.cmd, "AlphaRedraw")
        vim.schedule(function()
          local bufs = vim.api.nvim_list_bufs()
          for _, bufnr in ipairs(bufs) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == "alpha" then
              highlight_shortcuts(bufnr)
            end
          end
        end)
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function(ev)
        vim.opt_local.foldenable = false
        for _, action in ipairs(actions) do
          vim.keymap.set("n", action.key, action.run, {
            buffer = ev.buf,
            silent = true,
            nowait = true,
            desc = "Dashboard: " .. action.label,
          })
        end
        highlight_shortcuts(ev.buf)
      end,
    })
  end,
}
