return {
  "brianhuster/live-preview.nvim",
  dependencies = {
    -- You can choose one of the following pickers
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("livepreview.config").set({
      port = 5500,
      autokill = false,
      browser = "default",
      dynamic_root = false,
      sync_scroll = true,
      picker = "telescope",
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>ls", "<cmd>LivePreview start<cr>", { desc = "Start Live Server" })
    vim.keymap.set("n", "<leader>lc", "<cmd>LivePreview close<cr>", { desc = "Close Live Server" })
    vim.keymap.set("n", "<leader>lp", "<cmd>LivePreview pick<cr>", { desc = "Pick file to Live Server" })
    vim.keymap.set("n", "<leader>lh", "<cmd>LivePreview help<cr>", { desc = "Show Live Server help" })
  end,
}
