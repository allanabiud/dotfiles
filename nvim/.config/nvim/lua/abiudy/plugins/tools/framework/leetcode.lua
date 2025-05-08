return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("leetcode").setup({
      lang = "python3",
    })

    -- Keys
    vim.keymap.set("n", "<leader>L", "<cmd>Leet<cr>", { desc = "LeetCode" })
    vim.keymap.set("n", "<leader>Lr", "<cmd>Leet run<cr>", { desc = "LeetCode: Run" })
    vim.keymap.set("n", "<leader>Ls", "<cmd>Leet submit<cr>", { desc = "LeetCode: Submit" })
    vim.keymap.set("n", "<leader>Ld", "<cmd>Leet daily<cr>", { desc = "LeetCode: Daily" })
    vim.keymap.set("n", "<leader>Ll", "<cmd>Leet list<cr>", { desc = "LeetCode: List Problems" })
    vim.keymap.set("n", "<leader>Lo", "<cmd>Leet open<cr>", { desc = "LeetCode: Open in Browser" })
    vim.keymap.set("n", "<leader>Li", "<cmd>Leet info<cr>", { desc = "LeetCode: Info" })
    vim.keymap.set("n", "<leader>Ly", "<cmd>Leet yank<cr>", { desc = "LeetCode: Yank Solution" })
    vim.keymap.set("n", "<leader>Lp", "<cmd>Leet tabs<cr>", { desc = "LeetCode: Tabs Picker" })
  end,
}
