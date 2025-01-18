return {
  "kawre/leetcode.nvim",
  build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
  dependencies = {
    "nvim-telescope/telescope.nvim",
    -- "ibhagwan/fzf-lua",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- configuration goes here
  },
  -- keymaps
  vim.keymap.set("n", "<leader>L", "<cmd>Leet<cr>", { desc = "Leetcode" }),
  vim.keymap.set("n", "<leader>Lc", "<cmd>Leet console<cr>", { desc = "Leetcode Console" }),
  vim.keymap.set("n", "<leader>Ld", "<cmd>Leet desc<cr>", { desc = "Toggle Question Description" }),
  vim.keymap.set("n", "<leader>Lm", "<cmd>Leet menu<cr>", { desc = "Leetcode Menu" }),
  vim.keymap.set("n", "<leader>Lt", "<cmd>Leet tabs<cr>", { desc = "Leetcode Tabs" }),
  vim.keymap.set("n", "<leader>Li", "<cmd>Leet info<cr>", { desc = "Leetcode Info" }),
  vim.keymap.set("n", "<leader>Ll", "<cmd>Leet lang<cr>", { desc = "Leetcode Language" }),
  vim.keymap.set("n", "<leader>Lr", "<cmd>Leet run<cr>", { desc = "Run" }),
  vim.keymap.set("n", "<leader>Ls", "<cmd>Leet submit<cr>", { desc = "Submit" }),
  vim.keymap.set("n", "<leader>Lq", "<cmd>Leet exit<cr>", { desc = "Exit" }),
  vim.keymap.set("n", "<leader>Lo", "<cmd>Leet open<cr>", { desc = "Open Problem in Browser" }),
  vim.keymap.set("n", "<leader>Ly", "<cmd>Leet yank<cr>", { desc = "Yank Code" }),
  vim.keymap.set("n", "<leader>Lpr", "<cmd>Leet reset<cr>", { desc = "Reset Question to Default Code Definition" }),
  vim.keymap.set("n", "<leader>Lps", "<cmd>Leet restore<cr>", { desc = "Restore Default Question Layout" }),
}
