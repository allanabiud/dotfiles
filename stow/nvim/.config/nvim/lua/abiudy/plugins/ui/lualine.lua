return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- Define a function to get the Flutter app version and device
    local function get_flutter_status()
      local device = vim.g.flutter_tools_decorations.device
      local device_name = device and (device.name or device.id) or "DEFAULT"
      local app_version = vim.g.flutter_tools_decorations.app_version
      return "󰱑 " .. app_version .. " | " .. device_name
    end

    -- configure lualine
    lualine.setup({
      options = {
        theme = "onedark_dark",
        component_separators = "|",
        section_separators = "",
      },
      sections = {
        lualine_b = {
          {
            "branch",
            icon = "",
            color = { fg = "#ff9e64" },
          },
        },
        lualine_c = {
          { "filename", path = 1 },
          { "diagnostics" },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "lsp_status", color = { fg = "#ff9e64" } },
          { "filetype" },
          { "encoding" },
        },
      },
    })
  end,
}
