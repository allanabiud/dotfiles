return {
  "https://github.com/fresh2dev/zellij.vim",
  -- Pin version to avoid breaking changes.
  -- tag = '0.3.*',
  lazy = false,
  config = function()
    vim.keymap.set("n", "<c-left>", "<cmd>ZellijNavigateLeft!<cr>", { desc = "Zellij: Navigate Left" })
    vim.keymap.set("n", "<c-right>", "<cmd>ZellijNavigateRight!<cr>", { desc = "Zellij: Navigate Right" })
    vim.keymap.set("n", "<c-up>", "<cmd>ZellijNavigateUp<cr>", { desc = "Zellij: Navigate Up" })
    vim.keymap.set("n", "<c-down>", "<cmd>ZellijNavigateDown<cr>", { desc = "Zellij: Navigate Down" })
    vim.keymap.set("n", "<c-p>", "<cmd>ZellijNewPaneVSplit<cr>", { desc = "Zellij: New Pane Vertical Split" })
    vim.keymap.set("n", "<c-t>", "<cmd>ZellijNewTab<cr>", { desc = "Zellij: New Tab" })
  end,
}
