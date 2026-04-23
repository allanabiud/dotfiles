return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")

      wk.add({
        { "<leader>c", group = "Code" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "Lazygit" },
        { "<leader>M", group = "Markdown" },
        { "<leader>r", group = "LSP" },
        { "<leader>s", group = "Search" },
        { "<leader>S", group = "Snacks" },
        { "<leader>t", group = "Tools" },
        { "<leader>tl", group = "Live Preview" },
        { "<leader>w", group = "Workspace Sessions" },
      })
    end,
  },
}
