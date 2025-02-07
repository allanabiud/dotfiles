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
