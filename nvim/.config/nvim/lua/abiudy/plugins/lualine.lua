return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- Define a function to get the Flutter app version and device
    local function get_flutter_status()
      local app_version = vim.g.flutter_tools_decorations.app_version or "No App Version"
      local device = vim.g.flutter_tools_decorations.device or "No Device"
      return app_version .. " | " .. device
    end

    -- configure lualine
    lualine.setup({
      options = {
        -- theme = "onedark",
        -- theme = "vscode",
        theme = "onedark_dark",
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
          -- Use the custom function to show Flutter app version and device
          { get_flutter_status, color = { fg = "#3e8fb0" } },
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}
