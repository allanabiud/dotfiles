return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- INPUT
    input = { enabled = true },
    -- NOTIFIER
    notifier = {
      enabled = true,
      timeout = 3000,
      render = "compact",
    },
    -- IMAGE
    image = {
      enabled = true,
      max_width = 40, -- Limit the maximum width
      max_height = 20, -- Limit the maximum height
      min_width = 10, -- Optional: Set a minimum width
      min_height = 5, -- Optional: Set a minimum height
      pos = { 1, 0 }, -- Position the image at the top-left corner
      markdown = {
        enabled = true,
        max_width = 80,
        max_height = 40,
      },
      wo = {
        wrap = false,
        number = false,
        relativenumber = false,
        cursorcolumn = false,
        signcolumn = "no",
        foldcolumn = "0",
        list = false,
        spell = false,
        statuscolumn = "",
      },
    },
    -- SCOPE
    scope = { enabled = true },
    -- QUICKFILE
    quickfile = { enabled = true },
    -- SCROLL
    scroll = { enabled = true },
    -- STATUSCOLUMN
    statuscolumn = { enabled = true },
    -- STYLES
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
    -- PICKER
    picker = {
      enabled = true,
      layout = {
        cycle = true,
      },
      keys = {
        ["/"] = "toggle_focus",
      },
    },
  },
  keys = {
    -- Notifications
    {
      "<leader>Sn",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    -- Buffer Actions
    {
      "<leader>Sbd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    -- Lazygit
    {
      "<leader>lg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>lf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Lazygit Current File History",
    },
    {
      "<leader>ll",
      function()
        Snacks.lazygit.log()
      end,
      desc = "Lazygit Log (cwd)",
    },
  },
}
