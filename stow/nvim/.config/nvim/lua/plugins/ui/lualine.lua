return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons", "AvengeMedia/base46" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    local function shorten_path(path)
      path = path:gsub(vim.env.HOME, "~")

      local win_width = vim.api.nvim_win_get_width(0)
      local max_len = math.floor(win_width * 0.25)

      if #path <= max_len then
        return path
      end

      local parts = vim.split(path, "/", { trimempty = true })
      local new_path = parts[#parts]

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

    local base46 = require("base46")

    if not base46.theme_tables["dms"] then
      base46.theme_tables["dms"] = {
        base_16 = {
          base00 = "#000000",
          base01 = "#000000",
          base02 = "#8ba39e",
          base03 = "#8ba39e",
          base04 = "#e0fff8",
          base05 = "#f2fffc",
          base06 = "#f2fffc",
          base07 = "#f2fffc",
          base08 = "#ff8142",
          base09 = "#ff8142",
          base0A = "#28ffd0",
          base0B = "#4eff59",
          base0C = "#8dffe6",
          base0D = "#28ffd0",
          base0E = "#4effd8",
          base0F = "#4effd8",
        },
        base_30 = {
          black = "#000000",
          white = "#f2fffc",
          one_bg = "#8ba39e",
          statusline_bg = "#28ffd0",
          blue = "#28ffd0",
          green = "#4eff59",
          red = "#ff8142",
          purple = "#4effd8",
          yellow = "#ff8142",
        },
      }
    end

    local function setup_lualine()
      local theme = require("lualine.themes._base46")("dms")
      local base46_colors = base46.theme_tables["dms"]

      vim.api.nvim_set_hl(0, "WinBarPath", { fg = base46_colors.base_16.base04 })
      vim.api.nvim_set_hl(0, "WinBarFile", { fg = base46_colors.base_16.base0A, bold = true })
      vim.api.nvim_set_hl(0, "WinBarBuf", { fg = base46_colors.base_16.base0D })

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
              color = { fg = theme.normal.b.fg, gui = "bold" },
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
              color = { fg = theme.normal.b.fg },
            },
            {
              lazy_status.updates,
              cond = lazy_status.has_updates,
              color = { fg = theme.normal.b.fg },
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
