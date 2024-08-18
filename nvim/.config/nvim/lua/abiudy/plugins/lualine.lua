return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- configure lualine
    lualine.setup({
      options = {
        -- theme = "onedark",
        theme = "vscode",
      },
      sections = {
        -- lualine_b = {
        --   {
        --     "branch",
        --     icon = "",
        --     color = { fg = "#ff9e64" },
        --   },
        -- },
        lualine_x = {
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
