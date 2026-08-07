return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- INPUT
    input = { enabled = true },
    -- NOTIFIER
    notifier = {
      enabled = true,
      timeout = 3000,
      render = "compact",
      margin = {
        top = 1,
      },
    },
    -- SCROLL
    scroll = { enabled = true },
    -- STATUSCOLUMN
    statuscolumn = { enabled = true },
    -- STYLES
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
    -- PICKER
    picker = {
      enabled = false,
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
      desc = "Notification history",
    },
    -- Buffer Actions
    {
      "<leader>Sbd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete buffer",
    },
    -- Lazygit
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Lazygit current file history",
    },
    {
      "<leader>gl",
      function()
        Snacks.lazygit.log()
      end,
      desc = "Lazygit log (cwd)",
    },
  },
}
