return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- configuration goes here
  },
  -- Keys
  vim.keymap.set("n", "<leader>tL", "<cmd>Leet<cr>", { desc = "LeetCode" }),
}
