return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    local function shorten_path(path)
      path = path:gsub(vim.env.HOME, "~")

      local win_width = vim.api.nvim_win_get_width(0)
      local max_len = math.floor(win_width * 0.25) -- use about 25% of window width for path

      if #path <= max_len then
        return path
      end

      local parts = vim.split(path, "/", { trimempty = true })
      local new_path = parts[#parts] -- start from the end (deepest directory)

      -- prepend dirs until we exceed limit
      for i = #parts - 1, 1, -1 do
        local test_path = parts[i] .. "/" .. new_path
        if #test_path + 3 > max_len then
          new_path = "…/" .. new_path
          break
        end
        new_path = test_path
      end

      return new_path
    end

    local function get_file_path()
      local path = vim.fn.expand("%:p:h")
      return shorten_path(path)
    end

    local function get_buffer_count()
      return "(" .. #vim.fn.getbufinfo({ buflisted = 1 }) .. ")"
    end

    local function setup_lualine()
      local base16 = require("base16-colorscheme").colors
      if not base16 then
        return
      end

      local colors = {
        bg = base16.base00,
        bg_alt = base16.base01,
        fg = base16.base05,
        fg_muted = base16.base04,
        accent = base16.base0D,
        green = base16.base0B,
        red = base16.base08,
      }

      local theme = {
        normal = {
          a = { fg = colors.bg, bg = colors.accent, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_alt },
          c = { fg = colors.fg_muted, bg = colors.bg },
        },
        insert = {
          a = { fg = colors.bg, bg = colors.green, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_alt },
          c = { fg = colors.fg_muted, bg = colors.bg },
        },
        visual = {
          a = { fg = colors.bg, bg = colors.accent, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_alt },
          c = { fg = colors.fg_muted, bg = colors.bg },
        },
        replace = {
          a = { fg = colors.bg, bg = colors.red, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_alt },
          c = { fg = colors.fg_muted, bg = colors.bg },
        },
        command = {
          a = { fg = colors.bg, bg = colors.accent, gui = "bold" },
          b = { fg = colors.fg, bg = colors.bg_alt },
          c = { fg = colors.fg_muted, bg = colors.bg },
        },
        inactive = {
          a = { fg = colors.fg_muted, bg = colors.bg },
          b = { fg = colors.fg_muted, bg = colors.bg },
          c = { fg = colors.fg_muted, bg = colors.bg },
        },
      }

      -- Define highlight groups
      vim.api.nvim_set_hl(0, "WinBarPath", { fg = base16.base04 })
      vim.api.nvim_set_hl(0, "WinBarFile", { fg = base16.base0A, bold = true })
      vim.api.nvim_set_hl(0, "WinBarBuf", { fg = base16.base0D })

      lualine.setup({
        options = {
          theme = theme,
          component_separators = "|",
          section_separators = "",
          globalstatus = true,
          disabled_filetypes = { winbar = { "neo-tree" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              "branch",
              icon = "",
              color = { fg = colors.fg, gui = "bold" },
            },
            { "diff" },
          },
          lualine_c = {
            { "diagnostics" },
          },
          lualine_x = {
            {
              require("noice").api.statusline.mode.get,
              cond = require("noice").api.statusline.mode.has,
              color = { fg = base16.base09 },
            },
            {
              lazy_status.updates,
              cond = lazy_status.has_updates,
              color = { fg = base16.base09 },
            },
            { "filetype" },
            { "encoding" },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_c = { "filename" },
          lualine_a = {},
          lualine_b = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_b = {
            {
              get_buffer_count,
              color = "WinBarBuf",
            },
          },
          lualine_c = {
            {
              "filename",
              path = 0,
              symbols = { modified = "[+]", readonly = "", unnamed = "[No Name]", newfile = "[New]" },
              color = "WinBarFile",
            },
          },
          lualine_x = {
            {
              get_file_path,
              color = "WinBarPath",
            },
          },
          lualine_a = {},
          lualine_y = {},
          lualine_z = {
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then
                  return "No LSP"
                end
                local names = {}
                for _, client in pairs(clients) do
                  table.insert(names, client.name)
                end
                return " " .. table.concat(names, ",")
              end,
            },
          },
        },
        inactive_winbar = {
          lualine_c = {
            {
              "filename",
              color = "WinBarFile",
            },
          },
        },
      })
    end

    setup_lualine()

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        setup_lualine()
      end,
    })
  end,
}
