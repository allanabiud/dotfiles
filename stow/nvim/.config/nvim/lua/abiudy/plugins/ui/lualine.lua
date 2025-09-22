return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")

    -- Define highlight groups
    vim.api.nvim_set_hl(0, "WinBarPath", { fg = "#a0a8b9" })
    vim.api.nvim_set_hl(0, "WinBarFile", { fg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "WinBarBuf", { fg = "#61afef" })

    local function get_buffer_count()
      return "(" .. #vim.fn.getbufinfo({ buflisted = 1 }) .. ")"
    end

    local function shorten_path(path)
      -- replace $HOME with ~
      path = path:gsub(vim.env.HOME, "~")

      -- split into parts
      local parts = vim.split(path, "/", { trimempty = true })
      if #parts <= 6 then
        return table.concat(parts, "/")
      end

      -- keep first 2 and last 4
      local new_parts = {}
      vim.list_extend(new_parts, { parts[1], parts[2] })
      table.insert(new_parts, "…")
      vim.list_extend(new_parts, {
        parts[#parts - 3],
        parts[#parts - 2],
        parts[#parts - 1],
        parts[#parts],
      })

      return table.concat(new_parts, "/")
    end

    local function get_file_path()
      return shorten_path(vim.fn.expand("%:p:h"))
    end

    lualine.setup({
      options = {
        theme = "onedark_dark",
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
            color = { fg = "#ff9e64" },
          },
        },
        lualine_c = {
          { "diagnostics" },
        },
        lualine_x = {
          {
            require("noice").api.statusline.mode.get,
            cond = require("noice").api.statusline.mode.has,
            color = { fg = "#ff9e64" },
          },
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
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
            symbols = { modified = "●", readonly = "", unnamed = "No Name" },
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
              return " " .. table.concat(names, " ")
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
  end,
}
